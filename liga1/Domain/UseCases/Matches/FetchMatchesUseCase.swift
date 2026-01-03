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
        return repository.fetchMatches(for: jornadaId)
    }
}
