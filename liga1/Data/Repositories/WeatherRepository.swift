//
//  WeatherRepository.swift
//  liga1
//

import Foundation
import FirebaseFirestore
import Combine

final class WeatherRepository: WeatherRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore { database.db }

    func fetchWeather(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error> {
        Future<MatchWeather?, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "WeatherRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }
            let jornada = jornadaId.trimmingCharacters(in: .whitespacesAndNewlines)
            let match = matchId.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !jornada.isEmpty, !match.isEmpty else { promise(.success(nil)); return }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornada)
                .collection(FirestoreConstants.Collection.matches)
                .document(match)
                .getDocument(source: .default) { snapshot, error in
                    if let error {
                        self.logger.error("WeatherRepository: fetch falló para \(jornada)/\(match)", error: error)
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot, snapshot.exists else {
                        promise(.success(nil))
                        return
                    }
                    do {
                        let envelope = try snapshot.data(as: MatchWeatherEnvelopeDTO.self)
                        guard let climaDTO = envelope.clima else {
                            promise(.success(nil))
                            return
                        }
                        promise(.success(MatchWeatherMapper.toDomain(from: climaDTO)))
                    } catch {
                        self.logger.error("WeatherRepository: decode de `clima` falló para \(jornada)/\(match)", error: error)
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
