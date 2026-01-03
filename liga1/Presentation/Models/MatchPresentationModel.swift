//
//  MatchPresentationModel.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import Foundation

/// Modelo de presentación para Match que incluye estado UI
/// Mantiene el Domain Model limpio de concerns de presentación
struct MatchPresentationModel {
    let match: Match
    var isFavorite: Bool
    var jornadaNumero: Int
    var torneoNombre: String

    init(match: Match, isFavorite: Bool = false, jornadaNumero: Int = 0, torneoNombre: String = "") {
        self.match = match
        self.isFavorite = isFavorite
        self.jornadaNumero = jornadaNumero
        self.torneoNombre = torneoNombre
    }
}

// MARK: - Convenience accessors

extension MatchPresentationModel {
    var id: String? { match.id }
    var equipoLocalId: String? { match.equipoLocalId }
    var equipoVisitanteId: String? { match.equipoVisitanteId }
    var golesEquipoLocal: Int { match.golesEquipoLocal }
    var golesEquipoVisitante: Int { match.golesEquipoVisitante }
    var estado: Match.EstadoMatch { match.estado }
    var fecha: Date { match.fecha }
    var suspendido: Bool { match.suspendido }
}
