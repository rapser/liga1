//
//  ObserveFavoriteTeamsUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 17/01/26.
//

import Foundation
import Combine

protocol ObserveFavoriteTeamsUseCaseProtocol {
    func execute() -> AnyPublisher<Set<String>, Never>
    func refreshFavoriteTeams() -> AnyPublisher<Void, Error>
}

final class ObserveFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute() -> AnyPublisher<Set<String>, Never> {
        return service.observeFavoriteTeams()
    }

    func refreshFavoriteTeams() -> AnyPublisher<Void, Error> {
        return service.fetchFavoriteTeams()
    }
}
