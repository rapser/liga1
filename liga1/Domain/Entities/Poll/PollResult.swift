//
//  PollResult.swift
//  liga1
//

import Foundation

/// Conteo agregado de una encuesta (suma de los shards) + el voto propio.
struct PollResult: Equatable {

    /// Votos por `optionId`.
    let tally: [String: Int]
    /// Opción que votó el usuario actual; `nil` si aún no vota.
    let myVote: String?

    static let empty = PollResult(tally: [:], myVote: nil)

    var totalVotos: Int {
        tally.values.reduce(0, +)
    }

    func votos(for optionId: String) -> Int {
        tally[optionId] ?? 0
    }

    /// Porcentaje entero (0 si no hay votos).
    func percent(for optionId: String) -> Int {
        let total = totalVotos
        guard total > 0 else { return 0 }
        return Int((Double(votos(for: optionId)) / Double(total) * 100).rounded())
    }

    var yaVote: Bool { myVote != nil }

    func withMyVote(_ optionId: String?) -> PollResult {
        PollResult(tally: tally, myVote: optionId)
    }
}
