//
//  ToggleFavoriteUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para marcar/desmarcar un partido como favorito
protocol ToggleFavoriteUseCaseProtocol {
    func execute(matchId: String) -> AnyPublisher<Void, Error>
}

class ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute(matchId: String) -> AnyPublisher<Void, Error> {
        return service.toggleFavorite(matchId: matchId)
    }
}
