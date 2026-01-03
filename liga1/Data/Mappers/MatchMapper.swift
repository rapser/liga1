//
//  MatchMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Mapper para convertir entre MatchDTO (Data Layer) y Match (Domain Layer)
struct MatchMapper {

    /// Convierte MatchDTO a Match (Domain Model)
    static func toDomain(from dto: MatchDTO) -> Match {
        return Match(
            id: dto.id,
            equipoLocalId: dto.equipoLocalId,
            equipoVisitanteId: dto.equipoVisitanteId,
            fecha: dto.fecha?.dateValue(),
            golesTeamA: dto.golesTeamA ?? 0,
            golesTeamB: dto.golesTeamB ?? 0,
            estado: dto.estado ?? "pendiente",
            suspendido: dto.suspendido ?? false
        )
    }

    /// Convierte Match (Domain Model) a MatchDTO
    static func toDTO(from domain: Match) -> MatchDTO {
        return MatchDTO(
            id: domain.id,
            equipoLocalId: domain.equipoLocalId,
            equipoVisitanteId: domain.equipoVisitanteId,
            fecha: domain.fecha != nil ? Timestamp(date: domain.fecha!) : nil,
            golesTeamA: domain.golesTeamA,
            golesTeamB: domain.golesTeamB,
            estado: domain.estado,
            suspendido: domain.suspendido
        )
    }

    /// Convierte array de MatchDTO a array de Match
    static func toDomainArray(from dtos: [MatchDTO]) -> [Match] {
        return dtos.map { toDomain(from: $0) }
    }
}
