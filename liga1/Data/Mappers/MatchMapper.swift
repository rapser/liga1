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
    static func toDomain(from dto: MatchDTO, logger: LoggerProtocol) -> Match? {
        guard let fecha = dto.fecha?.dateValue() else {
            return nil
        }

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

        let estadoMatch: Match.EstadoMatch
        if let estadoString = dto.estado {
            estadoMatch = Match.EstadoMatch(rawValue: estadoString) ?? .pendiente
        } else {
            estadoMatch = .pendiente
        }

        let live = dto.liveStats.flatMap { toDomainLiveStats($0) }

        return Match(
            id: matchId,
            equipoLocalId: dto.equipoLocalId,
            equipoVisitanteId: dto.equipoVisitanteId,
            fecha: fecha,
            golesEquipoLocal: dto.golesTeamA ?? 0,
            golesEquipoVisitante: dto.golesTeamB ?? 0,
            estado: estadoMatch,
            suspendido: dto.suspendido ?? false,
            arbitro: dto.arbitro,
            estadio: dto.estadio,
            capacidad: dto.capacidad,
            canalesTV: dto.canalesTV ?? [],
            liveStats: live
        )
    }

    private static func toDomainLiveStats(_ dto: MatchLiveStatsDTO) -> MatchLiveStats? {
        let m = MatchLiveStats(
            posesionLocal: dto.posesionLocal,
            posesionVisitante: dto.posesionVisitante,
            rematesLocal: dto.rematesLocal,
            rematesVisitante: dto.rematesVisitante,
            tirosAPuertaLocal: dto.tirosAPuertaLocal,
            tirosAPuertaVisitante: dto.tirosAPuertaVisitante,
            cornersLocal: dto.cornersLocal,
            cornersVisitante: dto.cornersVisitante
        )
        return m.isEmpty ? nil : m
    }

    /// Convierte Match (Domain Model) a MatchDTO
    static func toDTO(from domain: Match) -> MatchDTO {
        let statsDto = domain.liveStats.map {
            MatchLiveStatsDTO(
                posesionLocal: $0.posesionLocal,
                posesionVisitante: $0.posesionVisitante,
                rematesLocal: $0.rematesLocal,
                rematesVisitante: $0.rematesVisitante,
                tirosAPuertaLocal: $0.tirosAPuertaLocal,
                tirosAPuertaVisitante: $0.tirosAPuertaVisitante,
                cornersLocal: $0.cornersLocal,
                cornersVisitante: $0.cornersVisitante
            )
        }
        return MatchDTO(
            id: domain.id,
            equipoLocalId: domain.equipoLocalId,
            equipoVisitanteId: domain.equipoVisitanteId,
            fecha: Timestamp(date: domain.fecha),
            golesTeamA: domain.golesEquipoLocal,
            golesTeamB: domain.golesEquipoVisitante,
            estado: domain.estado.rawValue,
            suspendido: domain.suspendido,
            arbitro: domain.arbitro,
            estadio: domain.estadio,
            capacidad: domain.capacidad,
            canalesTV: domain.canalesTV.isEmpty ? nil : domain.canalesTV,
            liveStats: statsDto
        )
    }

    /// Convierte array de MatchDTO a array de Match
    static func toDomain(from dtos: [MatchDTO], logger: LoggerProtocol) -> [Match] {
        return dtos.compactMap { toDomain(from: $0, logger: logger) }
    }
}
