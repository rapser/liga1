//
//  JornadaMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Mapper para convertir entre JornadaDTO (Data Layer) y Jornada (Domain Layer)
struct JornadaMapper {

    /// Convierte JornadaDTO a Jornada (Domain Model)
    static func toDomain(from dto: JornadaDTO) -> Jornada {
        return Jornada(
            id: dto.id,
            mostrar: dto.mostrar ?? false,
            numero: dto.numero,
            torneo: dto.torneo,
            fechaInicio: dto.fechaInicio?.dateValue()
        )
    }

    /// Convierte Jornada (Domain Model) a JornadaDTO
    static func toDTO(from domain: Jornada) -> JornadaDTO {
        return JornadaDTO(
            id: domain.id,
            mostrar: domain.mostrar,
            numero: domain.numero,
            torneo: domain.torneo,
            fechaInicio: domain.fechaInicio != nil ? Timestamp(date: domain.fechaInicio!) : nil
        )
    }

    /// Convierte array de JornadaDTO a array de Jornada
    static func toDomainArray(from dtos: [JornadaDTO]) -> [Jornada] {
        return dtos.map { toDomain(from: $0) }
    }
}
