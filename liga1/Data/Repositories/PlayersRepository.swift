//
//  PlayersRepository.swift
//  liga1
//

import Foundation
import FirebaseFirestore
import Combine

final class PlayersRepository: PlayersRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore { database.db }

    func fetchSquad(teamId: String) -> AnyPublisher<[Player], Error> {
        Future<[Player], Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "PlayersRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }
            let id = teamId.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { promise(.success([])); return }

            self.db.collection(FirestoreConstants.Collection.teams)
                .document(id)
                .collection(FirestoreConstants.Collection.players)
                .whereField(FirestoreConstants.PlayerField.active, isEqualTo: true)
                .getDocuments(source: .default) { snapshot, error in
                    if let error {
                        self.logger.error("PlayersRepository: fetch falló para \(id)", error: error)
                        promise(.failure(error))
                        return
                    }

                    let players = (snapshot?.documents ?? []).compactMap { document -> Player? in
                        do {
                            let dto = try document.data(as: PlayerDTO.self)
                            return PlayerMapper.toDomain(from: dto, id: document.documentID)
                        } catch {
                            self.logger.error("PlayersRepository: decode falló para \(document.documentID)", error: error)
                            return nil
                        }
                    }
                    promise(.success(players))
                }
        }
        .eraseToAnyPublisher()
    }
}
