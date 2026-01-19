//
//  ToggleFavoriteTeamUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 17/01/26.
//

import Foundation
import Combine

protocol ToggleFavoriteTeamUseCaseProtocol {
    func execute(teamId: String) -> AnyPublisher<Bool, Error>
}

final class ToggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute(teamId: String) -> AnyPublisher<Bool, Error> {
        return service.toggleFavoriteTeam(teamId: teamId)
    }
}
