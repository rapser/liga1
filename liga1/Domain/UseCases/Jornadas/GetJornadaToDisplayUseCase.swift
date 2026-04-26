//
//  GetJornadaToDisplayUseCase.swift
//  liga1
//
//  Created by plan implementation.
//

import Foundation
import Combine

/// Todas las jornadas con `mostrar == true` (el repositorio ya las filtra) para cargar partidos en Home.
protocol GetJornadaToDisplayUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Error>
    func observe() -> AnyPublisher<[Jornada], Never>
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

    func execute() -> AnyPublisher<[Jornada], Error> {
        return fetchActiveJornadasUseCase.execute()
            .map { Self.orderJornadasForHome($0) }
            .eraseToAnyPublisher()
    }

    func observe() -> AnyPublisher<[Jornada], Never> {
        return observeActiveJornadasUseCase.execute()
            .map { Self.orderJornadasForHome($0) }
            .eraseToAnyPublisher()
    }

    /// Orden solo por torneo, número e id — sin usar `fechaInicio` (la fecha visible la elige el usuario en el calendario).
    static func orderJornadasForHome(_ jornadas: [Jornada]) -> [Jornada] {
        jornadas.sorted {
            if $0.torneo != $1.torneo { return $0.torneo < $1.torneo }
            if $0.numero != $1.numero { return $0.numero < $1.numero }
            return $0.id < $1.id
        }
    }
}
