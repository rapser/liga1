//
//  ToggleFavoriteUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para marcar/desmarcar un partido como favorito
protocol ToggleFavoriteUseCaseProtocol {
    func execute(matchId: String) -> AnyPublisher<Void, Error>
}

class ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {

    private let service: FavoritesServiceProtocol

    init(service: FavoritesServiceProtocol) {
        self.service = service
    }

    func execute(matchId: String) -> AnyPublisher<Void, Error> {
        // Validación de negocio
        guard !matchId.isEmpty else {
            Logger.shared.error("ToggleFavoriteUseCase: matchId is empty", error: nil)
            return Fail(error: NSError(
                domain: "ToggleFavoriteUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "El ID del partido no puede estar vacío"]
            )).eraseToAnyPublisher()
        }


        return service.toggleFavorite(matchId: matchId)
            .map { _ in () }  // Convertir Bool a Void
            .handleEvents(
                receiveOutput: { _ in
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("ToggleFavoriteUseCase: Failed to toggle favorite for match \(matchId)", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
