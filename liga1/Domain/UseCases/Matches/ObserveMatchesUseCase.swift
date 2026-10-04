//
//  ObserveMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

protocol ObserveMatchesUseCaseProtocol {
    func execute(for jornadaId: String) -> AnyPublisher<[Match], Never>
    /// Fuerza una relectura desde el servidor; útil al volver de background si el
    /// listener en tiempo real quedó desincronizado.
    func refresh(for jornadaId: String)
}

class ObserveMatchesUseCase: ObserveMatchesUseCaseProtocol {

    private let repository: MatchesRepositoryProtocol

    init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for jornadaId: String) -> AnyPublisher<[Match], Never> {

        return repository.observeMatches(for: jornadaId)
            .handleEvents(
                receiveOutput: { matches in
                }
            )
            .eraseToAnyPublisher()
    }

    func refresh(for jornadaId: String) {
        repository.refreshMatches(for: jornadaId)
    }
}
