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
}

final class ObserveFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute() -> AnyPublisher<Set<String>, Never> {
        return service.observeFavoriteTeams()
    }
}
