//
//  JornadaMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre JornadaDTO (Data Layer) y Jornada (Domain Layer)
struct JornadaMapper {

    /// Convierte JornadaDTO a Jornada (Domain Model)
    /// Nota: Jornada tiene propiedades computadas (torneo, numero) que se extraen del id
    static func toDomain(from dto: JornadaDTO) -> Jornada? {
        // Jornada requiere mostrar y fechaInicio como propiedades stored
        guard let mostrar = dto.mostrar,
              let fechaInicio = dto.fechaInicio?.dateValue() else {
            return nil
        }

        // Usar inicializador desde diccionario para crear Jornada
        var dict: [String: Any] = [
            "mostrar": mostrar,
            "fechaInicio": Timestamp(date: fechaInicio)
        ]

        if let id = dto.id {
            dict["id"] = id
        }

        // Decodificar desde diccionario
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let jornada = try? JSONDecoder().decode(Jornada.self, from: data) else {
            return nil
        }

        return jornada
    }

    /// Convierte Jornada (Domain Model) a JornadaDTO
    static func toDTO(from domain: Jornada) -> JornadaDTO {
        return JornadaDTO(
            id: domain.id,
            mostrar: domain.mostrar,
            numero: domain.numero,
            torneo: domain.torneo,
            fechaInicio: Timestamp(date: domain.fechaInicio)
        )
    }

    /// Convierte array de JornadaDTO a array de Jornada
    static func toDomainArray(from dtos: [JornadaDTO]) -> [Jornada] {
        return dtos.compactMap { toDomain(from: $0) }
    }
}
