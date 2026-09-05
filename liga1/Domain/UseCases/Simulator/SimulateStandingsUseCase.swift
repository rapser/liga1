//
//  SimulateStandingsUseCase.swift
//  liga1
//

import Foundation

protocol SimulateStandingsUseCaseProtocol {
    /// Aplica los resultados proyectados sobre la tabla base y devuelve la tabla
    /// resultante, ordenada con los criterios de desempate de la Liga 1.
    /// Función pura: mismas entradas ⇒ misma salida, sin efectos.
    func execute(base: [Team], predictions: [MatchPrediction]) -> [Team]
}

final class SimulateStandingsUseCase: SimulateStandingsUseCaseProtocol {

    func execute(base: [Team], predictions: [MatchPrediction]) -> [Team] {
        // Índice por código de equipo (`logo`). Se ignoran equipos duplicados.
        var byCode: [String: Team] = [:]
        for team in base where byCode[team.logo] == nil {
            byCode[team.logo] = team
        }

        for prediction in predictions {
            apply(prediction, to: &byCode)
        }

        return Array(byCode.values).sorted { Team.isOrderedAboveInStandings($0, $1) }
    }

    private func apply(_ p: MatchPrediction, to byCode: inout [String: Team]) {
        guard var home = byCode[p.homeCode], var away = byCode[p.awayCode] else { return }

        home.partidosJugados += 1
        away.partidosJugados += 1

        home.golesFavor += p.homeGoals
        home.golesContra += p.awayGoals
        away.golesFavor += p.awayGoals
        away.golesContra += p.homeGoals

        switch p.outcome {
        case .home:
            home.partidosGanados += 1
            home.puntos += 3
            away.partidosPerdidos += 1
        case .away:
            away.partidosGanados += 1
            away.puntos += 3
            home.partidosPerdidos += 1
        case .draw:
            home.partidosEmpatados += 1
            away.partidosEmpatados += 1
            home.puntos += 1
            away.puntos += 1
        }

        home.diferenciaGoles = home.golesFavor - home.golesContra
        away.diferenciaGoles = away.golesFavor - away.golesContra

        byCode[p.homeCode] = home
        byCode[p.awayCode] = away
    }
}
