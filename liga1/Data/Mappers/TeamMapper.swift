//
//  TeamMapper.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation

/// Mapper para convertir entre TeamDTO (Data Layer) y Team (Domain Layer)
struct TeamMapper {

    /// Convierte TeamDTO a Team (Domain Model)
    static func toDomain(from dto: TeamDTO, documentID: String? = nil) -> Team {
        // Usar el logo del DTO, o el documentID como fallback si no está presente
        let logo = dto.logo ?? documentID ?? ""
        
        return Team(
            nombre: dto.name ?? "",
            ciudad: dto.city ?? "",
            estadio: dto.stadium ?? "",
            logo: logo,
            partidosJugados: dto.matchesPlayed ?? 0,
            partidosGanados: dto.matchesWon ?? 0,
            partidosEmpatados: dto.matchesDrawn ?? 0,
            partidosPerdidos: dto.matchesLost ?? 0,
            golesFavor: dto.goalsScored ?? 0,
            golesContra: dto.goalsAgainst ?? 0,
            diferenciaGoles: dto.goalDifference ?? 0,
            puntos: dto.points ?? 0
        )
    }

    /// Convierte Team (Domain Model) a TeamDTO
    static func toDTO(from domain: Team) -> TeamDTO {
        return TeamDTO(
            id: nil,  // ID se genera en Firestore
            name: domain.nombre,
            city: domain.ciudad,
            stadium: domain.estadio,
            logo: domain.logo,
            matchesPlayed: domain.partidosJugados,
            matchesWon: domain.partidosGanados,
            matchesDrawn: domain.partidosEmpatados,
            matchesLost: domain.partidosPerdidos,
            goalsScored: domain.golesFavor,
            goalsAgainst: domain.golesContra,
            goalDifference: domain.diferenciaGoles,
            points: domain.puntos
        )
    }

    /// Convierte array de TeamDTO a array de Team
    static func toDomainArray(from dtos: [TeamDTO], documentIDs: [String]? = nil) -> [Team] {
        if let documentIDs = documentIDs, documentIDs.count == dtos.count {
            return zip(dtos, documentIDs).map { toDomain(from: $0, documentID: $1) }
        }
        return dtos.map { toDomain(from: $0) }
    }
}
