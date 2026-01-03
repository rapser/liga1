//
//  MatchMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre MatchDTO (Data Layer) y Match (Domain Layer)
struct MatchMapper {

    /// Convierte MatchDTO a Match (Domain Model)
    static func toDomain(from dto: MatchDTO) -> Match {
        // Convertir estado de String a EstadoMatch enum
        let estadoMatch: Match.EstadoMatch
        if let estadoString = dto.estado {
            estadoMatch = Match.EstadoMatch(rawValue: estadoString) ?? .pendiente
        } else {
            estadoMatch = .pendiente
        }

        return Match(
            id: dto.id,
            fecha: dto.fecha?.dateValue() ?? Date(),
            golesEquipoLocal: dto.golesTeamA ?? 0,
            golesEquipoVisitante: dto.golesTeamB ?? 0,
            estado: estadoMatch,
            suspendido: dto.suspendido ?? false,
            isFavorite: false
        )
    }

    /// Convierte Match (Domain Model) a MatchDTO
    static func toDTO(from domain: Match) -> MatchDTO {
        return MatchDTO(
            id: domain.id,
            equipoLocalId: domain.equipoLocalId,
            equipoVisitanteId: domain.equipoVisitanteId,
            fecha: Timestamp(date: domain.fecha),
            golesTeamA: domain.golesEquipoLocal,
            golesTeamB: domain.golesEquipoVisitante,
            estado: domain.estado.rawValue,
            suspendido: domain.suspendido
        )
    }

    /// Convierte array de MatchDTO a array de Match
    static func toDomainArray(from dtos: [MatchDTO]) -> [Match] {
        return dtos.map { toDomain(from: $0) }
    }
}
