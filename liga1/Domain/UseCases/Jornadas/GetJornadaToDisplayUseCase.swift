//
//  GetJornadaToDisplayUseCase.swift
//  liga1
//
//  Created by plan implementation.
//

import Foundation
import Combine

/// Jornadas que Home debe cargar: con horarios oficiales confirmados (el repositorio ya las filtra)
/// y dentro de la ventana de Home (`Jornada.isVisibleInHome`: hasta 7 días antes de su primer partido).
protocol GetJornadaToDisplayUseCaseProtocol {
    func execute() -> AnyPublisher<[Jornada], Error>
    func observe() -> AnyPublisher<[Jornada], Never>
}

final class GetJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol {

    private let fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol
    private let observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol
    private let now: () -> Date

    init(
        fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol,
        observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol,
        now: @escaping () -> Date = Date.init
    ) {
        self.fetchActiveJornadasUseCase = fetchActiveJornadasUseCase
        self.observeActiveJornadasUseCase = observeActiveJornadasUseCase
        self.now = now
    }

    func execute() -> AnyPublisher<[Jornada], Error> {
        return fetchActiveJornadasUseCase.execute()
            .map { [now] in Self.jornadasForHome($0, now: now()) }
            .eraseToAnyPublisher()
    }

    func observe() -> AnyPublisher<[Jornada], Never> {
        return observeActiveJornadasUseCase.execute()
            .map { [now] in Self.jornadasForHome($0, now: now()) }
            .eraseToAnyPublisher()
    }

    /// Jornadas visibles en Home (confirmadas y dentro de la ventana de 7 días), ordenadas.
    static func jornadasForHome(_ jornadas: [Jornada], now: Date) -> [Jornada] {
        orderJornadasForHome(jornadas.filter { $0.isVisibleInHome(now: now) })
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
