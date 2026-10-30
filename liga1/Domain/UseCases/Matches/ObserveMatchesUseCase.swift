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
    /// `true` cuando los partidos de la jornada están confirmados por el servidor.
    func observeConfirmed(for jornadaId: String) -> AnyPublisher<Bool, Never>
    /// Fuerza una relectura desde el servidor; útil al volver de background si el
    /// listener en tiempo real quedó desincronizado.
    func refresh(for jornadaId: String, completion: ((Bool) -> Void)?)
}

extension ObserveMatchesUseCaseProtocol {
    func refresh(for jornadaId: String) {
        refresh(for: jornadaId, completion: nil)
    }
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

    func observeConfirmed(for jornadaId: String) -> AnyPublisher<Bool, Never> {
        repository.observeMatchesConfirmed(for: jornadaId)
    }

    func refresh(for jornadaId: String, completion: ((Bool) -> Void)?) {
        repository.refreshMatches(for: jornadaId, completion: completion)
    }
}
