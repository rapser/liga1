//
 //  NewsRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo NewsRepositoryProtocol
class NewsRepository: NewsRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore {
        database.db
    }

    func fetchNews() -> AnyPublisher<[NewsItem], Error> {
        return Future<[NewsItem], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "NewsRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }


            self.db.collection(FirestoreConstants.Collection.news)
                .order(by: FirestoreConstants.NewsField.fecha, descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        self.logger.error("NewsRepository: Error fetching documents", error: error)
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }


                    // Decodificar DTOs desde Firestore y asignar documentID manualmente
                    let newsDTOs = documents.compactMap { doc -> NewsItemDTO? in
                        guard var dto = try? doc.data(as: NewsItemDTO.self) else {
                            return nil
                        }
                        // Asignar el documentID si no está presente
                        if dto.id == nil || dto.id?.isEmpty == true {
                            dto = NewsItemDTO(
                                id: doc.documentID,
                                title: dto.title,
                                image: dto.image,
                                url: dto.url,
                                periodico: dto.periodico,
                                categoria: dto.categoria,
                                destacada: dto.destacada,
                                fecha: dto.fecha
                            )
                        }
                        return dto
                    }

                    // Convertir DTOs a entidades de dominio usando el mapper
                    let newsItems = NewsItemMapper.toDomain(from: newsDTOs)

                    promise(.success(newsItems))
                }
        }
        .eraseToAnyPublisher()
    }
}
