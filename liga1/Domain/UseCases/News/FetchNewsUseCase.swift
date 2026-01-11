//
//  FetchNewsUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener noticias
protocol FetchNewsUseCaseProtocol {
    func execute() -> AnyPublisher<[NewsItem], Error>
}

class FetchNewsUseCase: FetchNewsUseCaseProtocol {

    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[NewsItem], Error> {
        Logger.shared.debug("FetchNewsUseCase: Fetching news")

        return repository.fetchNews()
            .handleEvents(
                receiveOutput: { news in
                    Logger.shared.info("FetchNewsUseCase: Successfully fetched \(news.count) news items")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("FetchNewsUseCase: Failed to fetch news", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
