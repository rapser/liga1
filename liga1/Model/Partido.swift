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
    var golesTeamA: Int
    var golesTeamB: Int
    var estado: EstadoPartido // Enum para representar los estados posibles
    
    init(teamAId: String, teamBId: String, fecha: String, golesTeamA: Int, golesTeamB: Int) {
        self.teamAId = teamAId
        self.teamBId = teamBId
        self.fecha = fecha
        self.torneo = "clausura"
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
