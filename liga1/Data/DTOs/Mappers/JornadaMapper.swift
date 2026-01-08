//
//  JornadaMapper.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre JornadaDTO (Data Layer) y Jornada (Domain Layer)
struct JornadaMapper {

    /// Convierte JornadaDTO a Jornada (Domain Model puro)
    static func toDomain(from dto: JornadaDTO) -> Jornada? {
        guard let id = dto.id,
              let mostrar = dto.mostrar,
              let numero = dto.numero,
              let torneo = dto.torneo,
              let fechaInicio = dto.fechaInicio?.dateValue() else {
            return nil
        }

        return Jornada(
            id: id,
            torneo: torneo,
            numero: numero,
            mostrar: mostrar,
            fechaInicio: fechaInicio
        )
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
    static func toDomain(from dtos: [JornadaDTO]) -> [Jornada] {
        return dtos.compactMap { toDomain(from: $0) }
    }
}
