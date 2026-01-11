//
//  FetchFavoriteMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

/// Use Case para obtener los partidos favoritos del usuario
protocol FetchFavoriteMatchesUseCaseProtocol {
    func execute(favoriteMatchIds: Set<String>) -> AnyPublisher<[Match], Error>
}

final class FetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol {

    private let matchesRepository: MatchesRepositoryProtocol

    init(matchesRepository: MatchesRepositoryProtocol) {
        self.matchesRepository = matchesRepository
    }

    func execute(favoriteMatchIds: Set<String>) -> AnyPublisher<[Match], Error> {
        // Si no hay favoritos, retornar array vacío
        guard !favoriteMatchIds.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Obtener los partidos favoritos
        return matchesRepository.fetchMatchesByIds(matchIds: Array(favoriteMatchIds))
            .map { matches in
                // Ordenar por fecha
                matches.sorted { $0.fecha < $1.fecha }
            }
            .eraseToAnyPublisher()
    }
}
