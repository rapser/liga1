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
        return repository.fetchNews()
            .eraseToAnyPublisher()
    }
}
