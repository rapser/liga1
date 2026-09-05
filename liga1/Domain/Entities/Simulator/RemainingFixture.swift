//
//  RemainingFixture.swift
//  liga1
//

import Foundation

/// Partido pendiente de un torneo, listo para que el usuario proyecte su marcador.
struct RemainingFixture: Equatable, Hashable {
    /// Id del partido (`jornadas/{jornadaId}/matches/{id}`).
    let id: String
    let jornadaId: String
    let jornadaNumero: Int
    let homeCode: String
    let awayCode: String
    let fecha: Date

    /// Orden natural: por número de jornada y luego por fecha.
    static func isOrderedBefore(_ a: RemainingFixture, _ b: RemainingFixture) -> Bool {
        if a.jornadaNumero != b.jornadaNumero { return a.jornadaNumero < b.jornadaNumero }
        return a.fecha < b.fecha
    }
}
