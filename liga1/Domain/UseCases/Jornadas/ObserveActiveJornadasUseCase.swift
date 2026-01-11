//
//  ObserveActiveJornadasUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

/// Use Case para observar cambios en jornadas activas en tiempo real
protocol ObserveActiveJornadasUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Never>
}

class ObserveActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol {
    
    private let repository: JornadasRepositoryProtocol
    
    init(repository: JornadasRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Jornada], Never> {
        Logger.shared.debug("ObserveActiveJornadasUseCase: Starting to observe active jornadas")
        
        return repository.observeActiveJornadas()
            .handleEvents(
                receiveOutput: { jornadas in
                    Logger.shared.info("ObserveActiveJornadasUseCase: Jornadas updated, count: \(jornadas.count)")
                }
            )
            .eraseToAnyPublisher()
    }
}
