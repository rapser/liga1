//
//  CalculateAccumulatedStandingsUseCase.swift
//  liga1
//

protocol CalculateAccumulatedStandingsUseCaseProtocol {
    func execute(apertura: [Team], clausura: [Team]) -> [Team]
}

/// Calcula la tabla anual sin persistir una tercera colección en Firebase.
final class CalculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCaseProtocol {

    func execute(apertura: [Team], clausura: [Team]) -> [Team] {
        var teamsById: [String: Team] = [:]
        for team in apertura {
            teamsById[team.logo] = team
        }

        for team in clausura {
            guard let existing = teamsById[team.logo] else {
                teamsById[team.logo] = team
                continue
            }

            let goalsScored = existing.golesFavor + team.golesFavor
            let goalsAgainst = existing.golesContra + team.golesContra
            teamsById[team.logo] = Team(
                nombre: existing.nombre,
                ciudad: existing.ciudad,
                estadio: existing.estadio,
                logo: existing.logo,
                partidosJugados: existing.partidosJugados + team.partidosJugados,
                partidosGanados: existing.partidosGanados + team.partidosGanados,
                partidosEmpatados: existing.partidosEmpatados + team.partidosEmpatados,
                partidosPerdidos: existing.partidosPerdidos + team.partidosPerdidos,
                golesFavor: goalsScored,
                golesContra: goalsAgainst,
                diferenciaGoles: goalsScored - goalsAgainst,
                puntos: existing.puntos + team.puntos
            )
        }

        let accumulated = Array(teamsById.values)
        if accumulated.allSatisfy({ $0.puntos == 0 }) {
            return accumulated.sorted {
                $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending
            }
        }
        return accumulated.sorted { Team.isOrderedAboveInStandings($0, $1) }
    }
}
