//
//  AdminMatchRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para operaciones administrativas de partidos
protocol AdminMatchRepositoryProtocol {
    // Métodos de actualización (mantener si se usan)
    func updateMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error>
    func finalizeAllMatches() -> AnyPublisher<Void, Error>
    func saveMatches(_ matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error>
    
    /// Registra una jornada individual con sus partidos
    /// - Parameters:
    ///   - jornadaId: ID de la jornada (ej: "apertura_01")
    ///   - mostrar: Si la jornada debe mostrarse
    ///   - fechaInicio: Fecha de inicio de la jornada
    ///   - matches: Array de partidos de la jornada
    func registerJornadaWithMatches(jornadaId: String, mostrar: Bool, fechaInicio: Date, matches: [Match]) -> AnyPublisher<Void, Error>
    
    /// Registra todas las 17 jornadas del torneo Apertura
    func registerAllAperturaJornadas() -> AnyPublisher<Void, Error>
}
