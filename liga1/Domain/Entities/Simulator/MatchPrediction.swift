//
//  MatchPrediction.swift
//  liga1
//

import Foundation

/// Resultado proyectado por el usuario para un partido aún no jugado.
/// `homeCode` / `awayCode` son códigos de equipo (los mismos que `Team.logo`).
struct MatchPrediction: Equatable {

    enum Outcome: Equatable {
        case home
        case draw
        case away
    }

    /// Id del partido (`jornadas/{j}/matches/{id}`), útil para la UI; el motor no lo usa.
    let fixtureId: String
    let homeCode: String
    let awayCode: String
    let homeGoals: Int
    let awayGoals: Int

    init(fixtureId: String = "", homeCode: String, awayCode: String, homeGoals: Int, awayGoals: Int) {
        self.fixtureId = fixtureId
        self.homeCode = homeCode
        self.awayCode = awayCode
        self.homeGoals = max(0, homeGoals)
        self.awayGoals = max(0, awayGoals)
    }

    var outcome: Outcome {
        if homeGoals > awayGoals { return .home }
        if homeGoals < awayGoals { return .away }
        return .draw
    }
}
