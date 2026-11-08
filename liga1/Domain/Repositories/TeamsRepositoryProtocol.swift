//
//  TeamsRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener equipos
protocol TeamsRepositoryProtocol {
    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
    /// Invalida la caché en memoria para el torneo indicado (nil = todos).
    func invalidateCache(for torneo: TorneoType?)
    /// Sanciones de puntos de todos los equipos (`equipos/{code}.sanctions`).
    /// Solo aplican a la tabla acumulada. Nunca falla: sin datos devuelve `[]`.
    func fetchPointSanctions() -> AnyPublisher<[PointSanction], Never>
}
