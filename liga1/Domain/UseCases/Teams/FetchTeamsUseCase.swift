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
    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
}

class FetchTeamsUseCase: FetchTeamsUseCaseProtocol {

    private let repository: TeamsRepositoryProtocol

    init(repository: TeamsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        Logger.shared.debug("FetchTeamsUseCase: Fetching teams for torneo: \(torneo)")

        let torneoString: String
        switch torneo {
        case .apertura:
            torneoString = "Apertura"
        case .clausura:
            torneoString = "Clausura"
        case .acumulado:
            // Acumulado no debería llamar directamente a repository
            Logger.shared.error("FetchTeamsUseCase: Invalid torneo type 'acumulado' for single fetch")
            return Fail(error: NSError(
                domain: "FetchTeamsUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Cannot fetch 'acumulado' directly. Use apertura or clausura."]
            )).eraseToAnyPublisher()
        }

        return repository.fetchTeams(torneo: torneoString)
            .handleEvents(
                receiveOutput: { teams in
                    Logger.shared.info("FetchTeamsUseCase: Successfully fetched \(teams.count) teams for \(torneo)")
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
