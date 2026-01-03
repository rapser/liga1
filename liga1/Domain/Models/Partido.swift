//
//  Partido.swift
//  liga1
//
//  Created by miguel tomairo on 17/08/24.
//

import Foundation

struct Partido: Codable {

    let teamAId: String
    let teamBId: String
    let fecha: String
    let torneo: String
    let jornadaId: String
    var golesTeamA: Int
    var golesTeamB: Int
    var estado: EstadoPartido

    // Propiedades computadas para compatibilidad con RegisterMatchesUseCase
    var equipoA: String {
        return teamAId
    }

    var equipoB: String {
        return teamBId
    }

    init(teamAId: String, teamBId: String, fecha: String, jornadaId: String, torneo: String = "clausura", golesTeamA: Int = 0, golesTeamB: Int = 0) {
        self.teamAId = teamAId
        self.teamBId = teamBId
        self.fecha = fecha
        self.jornadaId = jornadaId
        self.torneo = torneo
        self.golesTeamA = golesTeamA
        self.golesTeamB = golesTeamB
        self.estado = .pendiente
    }

    enum EstadoPartido: String, Codable {
        case pendiente
        case enJuego
        case finalizado
    }
}
