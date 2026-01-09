//
//  TeamUIMapper.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Mapper para convertir entre Team (Domain layer) y TeamUI (Presentation layer)
struct TeamUIMapper {

    /// Convierte una entidad de dominio Team a un modelo de presentación TeamUI
    /// - Parameter domain: La entidad de dominio
    /// - Returns: El modelo de presentación
    static func toUI(from domain: Team) -> TeamUI {
        return TeamUI(
            nombre: domain.nombre,
            ciudad: domain.ciudad,
            estadio: domain.estadio,
            logo: domain.logo,
            partidosJugados: domain.partidosJugados,
            partidosGanados: domain.partidosGanados,
            partidosEmpatados: domain.partidosEmpatados,
            partidosPerdidos: domain.partidosPerdidos,
            golesFavor: domain.golesFavor,
            golesContra: domain.golesContra,
            diferenciaGoles: domain.diferenciaGoles,
            puntos: domain.puntos
        )
    }

    /// Convierte múltiples entidades de dominio a modelos de presentación
    /// - Parameter domains: Array de entidades de dominio
    /// - Returns: Array de modelos de presentación
    static func toUI(from domains: [Team]) -> [TeamUI] {
        return domains.map { toUI(from: $0) }
    }

    /// Convierte un modelo de presentación TeamUI a una entidad de dominio Team
    /// - Parameter ui: El modelo de presentación
    /// - Returns: La entidad de dominio
    static func toDomain(from ui: TeamUI) -> Team {
        return Team(
            nombre: ui.nombre,
            ciudad: ui.ciudad,
            estadio: ui.estadio,
            logo: ui.logo,
            partidosJugados: ui.partidosJugados,
            partidosGanados: ui.partidosGanados,
            partidosEmpatados: ui.partidosEmpatados,
            partidosPerdidos: ui.partidosPerdidos,
            golesFavor: ui.golesFavor,
            golesContra: ui.golesContra,
            diferenciaGoles: ui.diferenciaGoles,
            puntos: ui.puntos
        )
    }
}
