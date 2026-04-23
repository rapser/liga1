//
//  MatchUIMapper.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Mapper para convertir entre Match (Domain layer) y MatchUI (Presentation layer)
struct MatchUIMapper {

    /// Convierte una entidad de dominio Match a un modelo de presentación MatchUI
    /// - Parameter domain: La entidad de dominio
    /// - Returns: El modelo de presentación
    static func toUI(from domain: Match) -> MatchUI {
        return MatchUI(
            id: domain.id,
            equipoLocalId: domain.equipoLocalId,
            equipoVisitanteId: domain.equipoVisitanteId,
            fecha: domain.fecha,
            golesEquipoLocal: domain.golesEquipoLocal,
            golesEquipoVisitante: domain.golesEquipoVisitante,
            estado: domain.estado,
            suspendido: domain.suspendido
        )
    }

    /// Convierte múltiples entidades de dominio a modelos de presentación
    /// - Parameter domains: Array de entidades de dominio
    /// - Returns: Array de modelos de presentación
    static func toUI(from domains: [Match]) -> [MatchUI] {
        return domains.map { toUI(from: $0) }
    }

    /// Convierte un modelo de presentación MatchUI a una entidad de dominio Match
    /// - Parameter ui: El modelo de presentación
    /// - Returns: La entidad de dominio
    static func toDomain(from ui: MatchUI) -> Match {
        return Match(
            id: ui.id,
            equipoLocalId: ui.equipoLocalId,
            equipoVisitanteId: ui.equipoVisitanteId,
            fecha: ui.fecha,
            golesEquipoLocal: ui.golesEquipoLocal,
            golesEquipoVisitante: ui.golesEquipoVisitante,
            estado: ui.estado,
            suspendido: ui.suspendido
        )
    }
}
