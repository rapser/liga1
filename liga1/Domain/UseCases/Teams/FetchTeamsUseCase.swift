//
//  FetchTeamsUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener equipos de un torneo
protocol FetchTeamsUseCaseProtocol {
    func execute(torneo: String) -> AnyPublisher<[Team], Error>
}

class FetchTeamsUseCase: FetchTeamsUseCaseProtocol {

    private let repository: TeamsRepositoryProtocol

    init(repository: TeamsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(torneo: String) -> AnyPublisher<[Team], Error> {
        return repository.fetchTeams(torneo: torneo)
    }
}
