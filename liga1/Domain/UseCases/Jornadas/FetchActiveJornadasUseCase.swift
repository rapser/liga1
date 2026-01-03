//
//  FetchActiveJornadasUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener jornadas activas
protocol FetchActiveJornadasUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Error>
}

class FetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol {

    private let repository: JornadasRepositoryProtocol

    init(repository: JornadasRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Jornada], Error> {
        return repository.fetchActiveJornadas()
    }
}
