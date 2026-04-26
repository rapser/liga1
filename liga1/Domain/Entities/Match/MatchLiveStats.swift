//
//  MatchLiveStats.swift
//  liga1
//

import Foundation

/// Estadísticas comparativas local vs visitante (p. ej. desde Firestore `stats` o campos planos).
struct MatchLiveStats: Equatable {
    var posesionLocal: Int?
    var posesionVisitante: Int?
    var rematesLocal: Int?
    var rematesVisitante: Int?
    var tirosAPuertaLocal: Int?
    var tirosAPuertaVisitante: Int?
    var cornersLocal: Int?
    var cornersVisitante: Int?

    var isEmpty: Bool {
        [
            posesionLocal, posesionVisitante,
            rematesLocal, rematesVisitante,
            tirosAPuertaLocal, tirosAPuertaVisitante,
            cornersLocal, cornersVisitante
        ].allSatisfy { $0 == nil }
    }
}
