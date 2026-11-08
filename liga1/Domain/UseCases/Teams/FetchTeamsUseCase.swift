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
    /// Refresca en background la tabla del torneo de la jornada y el Acumulado.
    func refreshStandings(forJornadaId jornadaId: String, completion: @escaping (Bool) -> Void)
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

    func refreshStandings(forJornadaId jornadaId: String, completion: @escaping (Bool) -> Void) {
        repository.refreshStandings(for: Self.standingsAffected(byJornadaId: jornadaId), completion: completion)
    }

    /// Un resultado cambia la tabla de su torneo (prefijo del ID, ej. "clausura_15")
    /// y el Acumulado. Un ID sin torneo reconocible refresca Clausura y Acumulado.
    static func standingsAffected(byJornadaId jornadaId: String) -> [TorneoType] {
        let prefix = jornadaId.split(separator: "_").first.map(String.init) ?? ""
        switch TorneoType(rawValue: prefix) {
        case .apertura: return [.apertura, .acumulado]
        default: return [.clausura, .acumulado]
        }
    }

    func invalidateCache(for torneo: TorneoType?) {
        repository.invalidateCache(for: torneo)
    }
}
