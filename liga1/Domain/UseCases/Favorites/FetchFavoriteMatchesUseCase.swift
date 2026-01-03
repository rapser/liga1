//
//  FetchFavoriteMatchesUseCase.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
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
                // Marcar todos como favoritos y ordenar por fecha
                var favoriteMatches = matches.map { match in
                    var updatedMatch = match
                    updatedMatch.isFavorite = true
                    return updatedMatch
                }
                favoriteMatches.sort { $0.fecha < $1.fecha }
                return favoriteMatches
            }
            .eraseToAnyPublisher()
    }
}
