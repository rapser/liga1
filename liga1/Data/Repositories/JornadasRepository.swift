//
//  JornadasRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol JornadasRepositoryProtocol {
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
}

class JornadasRepository: JornadasRepositoryProtocol {

    private let database: DatabaseProtocol

    init(database: DatabaseProtocol) {
        self.database = database
    }

    private var db: Firestore {
        database.db
    }

    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error> {
        return Future<[Jornada], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "JornadasRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .whereField(FirestoreConstants.JornadaField.mostrar, isEqualTo: true)
                .order(by: FirestoreConstants.JornadaField.fechaInicio, descending: true)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    // Decodificar DTOs desde Firestore
                    let dtos = documents.compactMap { doc -> JornadaDTO? in
                        try? doc.data(as: JornadaDTO.self)
                    }

                    // Convertir DTOs a entidades de dominio usando el mapper
                    let jornadas = JornadaMapper.toDomain(from: dtos)

                    promise(.success(jornadas))
                }
        }
        .eraseToAnyPublisher()
    }
}
