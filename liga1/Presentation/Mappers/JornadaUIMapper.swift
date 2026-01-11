//
//  JornadaUIMapper.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Mapper para convertir entre Jornada (Domain layer) y JornadaUI (Presentation layer)
struct JornadaUIMapper {

    /// Convierte una entidad de dominio Jornada a un modelo de presentación JornadaUI
    /// - Parameter domain: La entidad de dominio
    /// - Returns: El modelo de presentación
    static func toUI(from domain: Jornada) -> JornadaUI {
        return JornadaUI(
            id: domain.id,
            torneo: domain.torneo,
            numero: domain.numero,
            mostrar: domain.mostrar,
            fechaInicio: domain.fechaInicio
        )
    }

    /// Convierte múltiples entidades de dominio a modelos de presentación
    /// - Parameter domains: Array de entidades de dominio
    /// - Returns: Array de modelos de presentación
    static func toUI(from domains: [Jornada]) -> [JornadaUI] {
        return domains.map { toUI(from: $0) }
    }

    /// Convierte un modelo de presentación JornadaUI a una entidad de dominio Jornada
    /// - Parameter ui: El modelo de presentación
    /// - Returns: La entidad de dominio
    static func toDomain(from ui: JornadaUI) -> Jornada {
        return Jornada(
            id: ui.id,
            torneo: ui.torneo,
            numero: ui.numero,
            mostrar: ui.mostrar,
            fechaInicio: ui.fechaInicio
        )
    }
}
