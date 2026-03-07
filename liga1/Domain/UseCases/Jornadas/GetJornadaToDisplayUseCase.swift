//
//  GetJornadaToDisplayUseCase.swift
//  liga1
//
//  Created by plan implementation.
//

import Foundation
import Combine

/// Use Case que devuelve la única jornada a mostrar en Home: la de menor fecha de inicio entre las activas (mostrar == true).
protocol GetJornadaToDisplayUseCaseProtocol {
    func execute() -> AnyPublisher<Jornada?, Error>
    func observe() -> AnyPublisher<Jornada?, Never>
}

final class GetJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol {

    private let fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol
    private let observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol

    init(
        fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol,
        observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol
    ) {
        self.fetchActiveJornadasUseCase = fetchActiveJornadasUseCase
        self.observeActiveJornadasUseCase = observeActiveJornadasUseCase
    }

    func execute() -> AnyPublisher<Jornada?, Error> {
        return fetchActiveJornadasUseCase.execute()
            .map { Self.selectJornadaToDisplay(from: $0) }
            .eraseToAnyPublisher()
    }

    func observe() -> AnyPublisher<Jornada?, Never> {
        return observeActiveJornadasUseCase.execute()
            .map { Self.selectJornadaToDisplay(from: $0) }
            .eraseToAnyPublisher()
    }

    /// Regla de negocio: de las jornadas con mostrar == true, la de menor fecha de inicio.
    static func selectJornadaToDisplay(from jornadas: [Jornada]) -> Jornada? {
        return jornadas.min(by: { $0.fechaInicio < $1.fechaInicio })
    }
}
