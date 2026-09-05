//
//  StadiumRepository.swift
//  liga1
//

import Foundation
import FirebaseFirestore
import Combine

final class StadiumRepository: StadiumRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore { database.db }

    func fetchStadium(forHomeTeam teamCode: String) -> AnyPublisher<Stadium?, Error> {
        Future<Stadium?, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "StadiumRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }
            let code = teamCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !code.isEmpty else { promise(.success(nil)); return }

            self.db.collection(FirestoreConstants.Collection.stadiums)
                .whereField("homeTeamCodes", arrayContains: code)
                .limit(to: 1)
                .getDocuments(source: .default) { snapshot, error in
                    if let error {
                        self.logger.error("StadiumRepository: fetch falló para \(code)", error: error)
                        promise(.failure(error))
                        return
                    }
                    guard let doc = snapshot?.documents.first else {
                        promise(.success(nil))
                        return
                    }
                    do {
                        let dto = try doc.data(as: StadiumDTO.self)
                        promise(.success(StadiumMapper.toDomain(from: dto, code: doc.documentID)))
                    } catch {
                        self.logger.error("StadiumRepository: decode falló para \(doc.documentID)", error: error)
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
