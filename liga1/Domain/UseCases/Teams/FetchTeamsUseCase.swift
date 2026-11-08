//
//  FetchTeamsUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener equipos de un torneo
protocol FetchTeamsUseCaseProtocol {
    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
    /// Tabla en tiempo real (caché persistente primero, luego servidor).
    func observe(for torneo: TorneoType) -> AnyPublisher<[Team], Never>
    /// Sanciones en tiempo real, para la leyenda y la marca del Acumulado.
    func observePointSanctions() -> AnyPublisher<[PointSanction], Never>
    func invalidateCache(for torneo: TorneoType?)
}

class FetchTeamsUseCase: FetchTeamsUseCaseProtocol {

    private let repository: TeamsRepositoryProtocol

    init(repository: TeamsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        repository.fetchTeams(for: torneo)
    }

    func observe(for torneo: TorneoType) -> AnyPublisher<[Team], Never> {
        repository.observeTeams(for: torneo)
    }

    func observePointSanctions() -> AnyPublisher<[PointSanction], Never> {
        repository.observePointSanctions()
    }

    func invalidateCache(for torneo: TorneoType?) {
        repository.invalidateCache(for: torneo)
    }
}
