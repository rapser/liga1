//
//  ObserveFavoritesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

protocol ObserveFavoritesUseCaseProtocol {
    func execute() -> AnyPublisher<Set<String>, Never>
}

class ObserveFavoritesUseCase: ObserveFavoritesUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute() -> AnyPublisher<Set<String>, Never> {

        return service.observeFavorites()
            .handleEvents(
                receiveOutput: { favoriteIds in
                }
            )
            .eraseToAnyPublisher()
    }
}
