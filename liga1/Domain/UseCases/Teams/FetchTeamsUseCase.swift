//
//  FetchTeamsUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener equipos de un torneo
protocol FetchTeamsUseCaseProtocol {
    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
    func invalidateCache(for torneo: TorneoType?)
}

class FetchTeamsUseCase: FetchTeamsUseCaseProtocol {

    private let repository: TeamsRepositoryProtocol

    init(repository: TeamsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        if torneo == .acumulado {
            return Fail(error: NSError(
                domain: "FetchTeamsUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Cannot fetch 'acumulado' directly. Use apertura or clausura."]
            )).eraseToAnyPublisher()
        }
        return repository.fetchTeams(for: torneo)
            .eraseToAnyPublisher()
    }

    func invalidateCache(for torneo: TorneoType?) {
        repository.invalidateCache(for: torneo)
    }
}
