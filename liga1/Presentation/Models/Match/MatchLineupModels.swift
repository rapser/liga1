//
//  MatchLineupModels.swift
//  liga1
//
//  Formación táctica (4-4-2, 4-2-3-1, 3-5-2, …) y datos de jugador para la pestaña Alineaciones.
//

import Foundation

/// Formación sin contar arquero: cada entero es cantidad de jugadores en esa línea, de atrás hacia adelante.
/// Ej.: 4-2-3-1 → `[4, 2, 3, 1]` (10 de campo + 1 arquero = 11).
struct FootballFormation: Equatable, Sendable {
    let lines: [Int]

    var code: String { lines.map(String.init).joined(separator: "-") }

    var totalFieldPlayers: Int { lines.reduce(0, +) }

    /// Arquero + líneas de campo.
    var totalSlots: Int { 1 + totalFieldPlayers }

    init?(lines: [Int]) {
        guard !lines.isEmpty,
              lines.allSatisfy({ $0 > 0 }),
              1 + lines.reduce(0, +) == 11 else { return nil }
        self.lines = lines
    }

    /// Parsea cadenas como `"4-2-3-1"`, `"3-5-2"`, `"4 - 4 - 2"`.
    static func parseCode(_ raw: String) -> FootballFormation? {
        let parts = raw
            .split { $0 == "-" || $0.isWhitespace }
            .compactMap { Int(String($0)) }
        return FootballFormation(lines: parts)
    }

    /// Parte la lista de jugadores en filas (primera fila = arquero, luego cada línea de `lines`).
    func rowSlices(of players: [LineupPlayerUIData]) -> [[LineupPlayerUIData]] {
        precondition(players.count == totalSlots)
        var rows: [[LineupPlayerUIData]] = []
        var idx = 0
        let counts = [1] + lines
        for c in counts {
            rows.append(Array(players[idx..<(idx + c)]))
            idx += c
        }
        return rows
    }
}

struct LineupPlayerUIData: Equatable, Sendable {
    let number: Int
    let shortName: String
    let rating: Double?
    let scoredGoal: Bool

    init(number: Int, shortName: String, rating: Double? = nil, scoredGoal: Bool = false) {
        self.number = number
        self.shortName = shortName
        self.rating = rating
        self.scoredGoal = scoredGoal
    }
}

struct TeamLineupSideModel: Equatable {
    let teamName: String
    let formation: FootballFormation
    let players: [LineupPlayerUIData]
    let averageRating: Double?

    init?(teamName: String, formation: FootballFormation, players: [LineupPlayerUIData], averageRating: Double?) {
        guard players.count == formation.totalSlots else { return nil }
        self.teamName = teamName
        self.formation = formation
        self.players = players
        self.averageRating = averageRating
    }
}

struct MatchLineupTabModel: Equatable {
    /// Equipo visitante (mitad superior de la cancha, hacia el centro).
    let visitTop: TeamLineupSideModel
    /// Equipo local (mitad inferior).
    let localBottom: TeamLineupSideModel
}
