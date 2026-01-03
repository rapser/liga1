//
//  NewsRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol NewsRepositoryProtocol {
    func fetchNews() -> AnyPublisher<[NewsItem], Error>
}

class NewsRepository: NewsRepositoryProtocol {

    private let database: DatabaseProtocol

    init(database: DatabaseProtocol) {
        self.database = database
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

            Logger.shared.debug("NewsRepository: Fetching from collection: \(FirestoreConstants.Collection.news)")

            self.db.collection(FirestoreConstants.Collection.news)
                .order(by: FirestoreConstants.NewsField.fecha, descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        Logger.shared.error("NewsRepository: Error fetching documents", error: error)
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        Logger.shared.debug("NewsRepository: No documents found, returning empty array")
                        promise(.success([]))
                        return
                    }

                    Logger.shared.debug("NewsRepository: Found \(documents.count) documents")

                    let newsItems = documents.compactMap { document -> NewsItem? in
                        Logger.shared.debug("NewsRepository: Processing document: \(document.documentID)")
                        Logger.shared.debug("NewsRepository: Document data: \(document.data())")
                        let item = NewsItem(from: document.data())
                        if item == nil {
                            Logger.shared.debug("NewsRepository: Failed to parse document \(document.documentID)")
                        }
                        return item
                    }

                    Logger.shared.debug("NewsRepository: Successfully parsed \(newsItems.count) news items")
                    promise(.success(newsItems))
                }
        }
        .eraseToAnyPublisher()
    }
}
