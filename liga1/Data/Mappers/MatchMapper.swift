//
//  MatchMapper.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre MatchDTO (Data Layer) y Match (Domain Layer)
struct MatchMapper {

    /// Convierte MatchDTO a Match (Domain Model)
    static func toDomain(from dto: MatchDTO) -> Match? {
        guard let fecha = dto.fecha?.dateValue() else {
            return nil
        }

        // Construir el id: si viene en el DTO lo usamos, sino lo construimos desde equipoLocalId y equipoVisitanteId
        let matchId: String
        if let id = dto.id, !id.isEmpty {
            matchId = id
        } else if let equipoLocalId = dto.equipoLocalId,
                  let equipoVisitanteId = dto.equipoVisitanteId,
                  !equipoLocalId.isEmpty,
                  !equipoVisitanteId.isEmpty {
            matchId = "\(equipoLocalId)_\(equipoVisitanteId)"
        } else {
            return nil
        }

        // Convertir estado de String a EstadoMatch enum
        let estadoMatch: Match.EstadoMatch
        if let estadoString = dto.estado {
            estadoMatch = Match.EstadoMatch(rawValue: estadoString) ?? .pendiente
        } else {
            estadoMatch = .pendiente
        }

        return Match(
            id: matchId,
            equipoLocalId: dto.equipoLocalId,
            equipoVisitanteId: dto.equipoVisitanteId,
            fecha: fecha,
            golesEquipoLocal: dto.golesTeamA ?? 0,
            golesEquipoVisitante: dto.golesTeamB ?? 0,
            estado: estadoMatch,
            suspendido: dto.suspendido ?? false
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
    static func toDomain(from dtos: [MatchDTO]) -> [Match] {
        return dtos.compactMap { toDomain(from: $0) }
    }
}
