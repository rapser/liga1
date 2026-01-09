//
 //  AdminMatchRepository.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo AdminMatchRepositoryProtocol
class AdminMatchRepository: AdminMatchRepositoryProtocol {

    private let database: DatabaseProtocol

    init(database: DatabaseProtocol) {
        self.database = database
    }

    private var db: Firestore {
        database.db
    }

    func registerMatch(match: Match, jornadaId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            // Estructura: jornadas/{jornadaId}/matches/{matchId}
            // matchId: adt_utc (código de 3 letras de cada equipo)
            guard !match.id.isEmpty else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Match ID is required"])))
                return
            }

            // Convertir Match (Domain) a MatchDTO (Data) usando el mapper
            let matchDTO = MatchMapper.toDTO(from: match)
            
            // Convertir MatchDTO a diccionario para Firestore
            do {
                let encoder = Firestore.Encoder()
                let data = try encoder.encode(matchDTO)
                
                self.db.collection(FirestoreConstants.Collection.jornadas)
                    .document(jornadaId)
                    .collection(FirestoreConstants.Collection.matches)
                    .document(match.id)
                    .setData(data) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func registerMultipleMatches(matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error> {
        let publishers = matches.map { registerMatch(match: $0, jornadaId: jornadaId) }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func updateMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .document(matchId)
                .updateData([
                    FirestoreConstants.MatchField.golesTeamA: localScore,
                    FirestoreConstants.MatchField.golesTeamB: visitorScore
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func updateLiveMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .document(matchId)
                .updateData([
                    FirestoreConstants.MatchField.golesTeamA: localScore,
                    FirestoreConstants.MatchField.golesTeamB: visitorScore,
                    FirestoreConstants.MatchField.estado: FirestoreConstants.MatchState.playing
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func finalizeMatch(matchId: String, jornadaId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .document(matchId)
                .updateData([
                    FirestoreConstants.MatchField.estado: FirestoreConstants.MatchState.finished
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func finalizeAllMatches() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.matches).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    promise(.success(()))
                    return
                }

                let batch = self.db.batch()

                for document in documents {
                    let matchRef = self.db.collection(FirestoreConstants.Collection.matches).document(document.documentID)
                    batch.updateData([FirestoreConstants.MatchField.estado: FirestoreConstants.MatchState.finished], forDocument: matchRef)
                }

                batch.commit { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveMatches(_ matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let batch = self.db.batch()
            let encoder = Firestore.Encoder()

            for match in matches {
                guard !match.id.isEmpty else { continue }
                
                // Convertir Match (Domain) a MatchDTO (Data) usando el mapper
                let matchDTO = MatchMapper.toDTO(from: match)
                
                // Convertir MatchDTO a diccionario para Firestore
                do {
                    let data = try encoder.encode(matchDTO)
                    let docRef = self.db.collection(FirestoreConstants.Collection.jornadas)
                        .document(jornadaId)
                        .collection(FirestoreConstants.Collection.matches)
                        .document(match.id)
                    batch.setData(data, forDocument: docRef)
                } catch {
                    Logger.shared.error("AdminMatchRepository: Failed to encode match \(match.id)", error: error)
                    // Continuar con el siguiente match
                }
            }

            batch.commit { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
