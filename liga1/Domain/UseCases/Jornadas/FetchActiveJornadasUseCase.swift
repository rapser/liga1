//
//  FetchActiveJornadasUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener jornadas activas
protocol FetchActiveJornadasUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Error>
}

class FetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol {

    private let repository: JornadasRepositoryProtocol
    private let logger: LoggerProtocol

    init(repository: JornadasRepositoryProtocol, logger: LoggerProtocol) {
        self.repository = repository
        self.logger = logger
    }

    func execute() -> AnyPublisher<[Jornada], Error> {

        return repository.fetchActiveJornadas()
            .handleEvents(
                receiveOutput: { jornadas in
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.logger.error("FetchActiveJornadasUseCase: Failed to fetch active jornadas", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
