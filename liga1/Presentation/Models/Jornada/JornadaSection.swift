//
//  JornadaSection.swift
//  liga1
//
//  Created by plan implementation.
//

import Foundation

/// Modelo de presentación para una sección de jornada en el Home (jornada + partidos).
struct JornadaSection {
    let jornadaId: String
    let numero: Int
    let torneo: String
    var matches: [MatchUI]
}
