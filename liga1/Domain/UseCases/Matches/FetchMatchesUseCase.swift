//
//  FetchMatchesUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener partidos de una jornada
protocol FetchMatchesUseCaseProtocol {
    func execute(for jornadaId: String) -> AnyPublisher<[Match], Error>
}

class FetchMatchesUseCase: FetchMatchesUseCaseProtocol {

    private let repository: MatchesRepositoryProtocol

    init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for jornadaId: String) -> AnyPublisher<[Match], Error> {
        // Validación de negocio
        guard !jornadaId.isEmpty else {
            Logger.shared.error("FetchMatchesUseCase: jornadaId is empty")
            return Fail(error: NSError(
                domain: "FetchMatchesUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )).eraseToAnyPublisher()
        }

        Logger.shared.debug("FetchMatchesUseCase: Fetching matches for jornada: \(jornadaId)")

        return repository.fetchMatches(for: jornadaId)
            .handleEvents(
                receiveOutput: { matches in
                    Logger.shared.info("FetchMatchesUseCase: Successfully fetched \(matches.count) matches for jornada \(jornadaId)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("FetchMatchesUseCase: Failed to fetch matches for jornada \(jornadaId)", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
