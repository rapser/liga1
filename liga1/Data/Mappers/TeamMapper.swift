//
//  TeamMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Mapper para convertir entre TeamDTO (Data Layer) y Team (Domain Layer)
struct TeamMapper {

    /// Convierte TeamDTO a Team (Domain Model)
    static func toDomain(from dto: TeamDTO) -> Team {
        return Team(
            id: dto.id,
            name: dto.name ?? "",
            city: dto.city,
            stadium: dto.stadium,
            matchesPlayed: dto.matchesPlayed ?? 0,
            matchesWon: dto.matchesWon ?? 0,
            matchesDrawn: dto.matchesDrawn ?? 0,
            matchesLost: dto.matchesLost ?? 0,
            goalsScored: dto.goalsScored ?? 0,
            goalsAgainst: dto.goalsAgainst ?? 0,
            goalDifference: dto.goalDifference ?? 0,
            points: dto.points ?? 0
        )
    }

    /// Convierte Team (Domain Model) a TeamDTO
    static func toDTO(from domain: Team) -> TeamDTO {
        return TeamDTO(
            id: domain.id,
            name: domain.name,
            city: domain.city,
            stadium: domain.stadium,
            matchesPlayed: domain.matchesPlayed,
            matchesWon: domain.matchesWon,
            matchesDrawn: domain.matchesDrawn,
            matchesLost: domain.matchesLost,
            goalsScored: domain.goalsScored,
            goalsAgainst: domain.goalsAgainst,
            goalDifference: domain.goalDifference,
            points: domain.points
        )
    }

    /// Convierte array de TeamDTO a array de Team
    static func toDomainArray(from dtos: [TeamDTO]) -> [Team] {
        return dtos.map { toDomain(from: $0) }
    }
}
