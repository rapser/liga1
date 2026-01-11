//
//  ObserveMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

/// Use Case para observar cambios en matches de una jornada en tiempo real
protocol ObserveMatchesUseCaseProtocol {
    func execute(for jornadaId: String) -> AnyPublisher<[Match], Never>
}

class ObserveMatchesUseCase: ObserveMatchesUseCaseProtocol {
    
    private let repository: MatchesRepositoryProtocol
    
    init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(for jornadaId: String) -> AnyPublisher<[Match], Never> {
        Logger.shared.debug("ObserveMatchesUseCase: Starting to observe matches for jornada: \(jornadaId)")
        
        return repository.observeMatches(for: jornadaId)
            .handleEvents(
                receiveOutput: { matches in
                    Logger.shared.info("ObserveMatchesUseCase: Matches updated for jornada \(jornadaId), count: \(matches.count)")
                }
            )
            .eraseToAnyPublisher()
    }
}
