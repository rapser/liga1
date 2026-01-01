//
//  JornadasRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol JornadasRepositoryProtocol {
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
}

class JornadasRepository: JornadasRepositoryProtocol {

    private let db = Firestore.firestore()

    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error> {
        return Future<[Jornada], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "JornadasRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection("jornadas")
                .whereField("mostrar", isEqualTo: true)
                .order(by: "numero", descending: false)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    let jornadas = documents.compactMap { doc -> Jornada? in
                        try? doc.data(as: Jornada.self)
                    }

                    promise(.success(jornadas))
                }
        }
        .eraseToAnyPublisher()
    }
}
