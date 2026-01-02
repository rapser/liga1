//
//  MatchesRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol MatchesRepositoryProtocol {
    func fetchMatches(for jornadaId: String) -> AnyPublisher<[Match], Error>
    func observeMatch(id: String) -> AnyPublisher<Match, Error>
}

class MatchesRepository: MatchesRepositoryProtocol {

    private let db = Firestore.firestore()

    func fetchMatches(for jornadaId: String) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "MatchesRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection("jornadas")
                .document(jornadaId)
                .collection("matches")
                .order(by: "fecha")
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    let matches = documents.compactMap { doc -> Match? in
                        try? doc.data(as: Match.self)
                    }

                    promise(.success(matches))
                }
        }
        .eraseToAnyPublisher()
    }

    func observeMatch(id: String) -> AnyPublisher<Match, Error> {
        // Future implementation for real-time match updates
        return Future<Match, Error> { promise in
            promise(.failure(NSError(domain: "MatchesRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])))
        }
        .eraseToAnyPublisher()
    }
}
