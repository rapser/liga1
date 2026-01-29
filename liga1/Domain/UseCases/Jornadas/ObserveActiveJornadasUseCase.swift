//
//  ObserveActiveJornadasUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

protocol ObserveActiveJornadasUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Never>
}

class ObserveActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol {
    
    private let repository: JornadasRepositoryProtocol
    
    init(repository: JornadasRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Jornada], Never> {
        
        return repository.observeActiveJornadas()
            .handleEvents(
                receiveOutput: { jornadas in
                }
            )
            .eraseToAnyPublisher()
    }
}
