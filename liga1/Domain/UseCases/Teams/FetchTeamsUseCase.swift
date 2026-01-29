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
}

class FetchTeamsUseCase: FetchTeamsUseCaseProtocol {

    private let repository: TeamsRepositoryProtocol

    init(repository: TeamsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {

        // Validar que no sea acumulado
        if torneo == .acumulado {
            Logger.shared.error("FetchTeamsUseCase: Invalid torneo type 'acumulado' for single fetch", error: nil)
            return Fail(error: NSError(
                domain: "FetchTeamsUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Cannot fetch 'acumulado' directly. Use apertura or clausura."]
            )).eraseToAnyPublisher()
        }

        return repository.fetchTeams(for: torneo)
            .handleEvents(
                receiveOutput: { teams in
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("FetchTeamsUseCase: Failed to fetch teams for \(torneo)", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
