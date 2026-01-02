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

    private let db = Firestore.firestore()

    func fetchNews() -> AnyPublisher<[NewsItem], Error> {
        return Future<[NewsItem], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "NewsRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection("news")
                .order(by: "fecha", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    let newsItems = documents.compactMap { NewsItem(from: $0.data()) }
                    promise(.success(newsItems))
                }
        }
        .eraseToAnyPublisher()
    }
}
