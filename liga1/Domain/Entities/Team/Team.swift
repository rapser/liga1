//
//  Team.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation

/// Entidad de dominio pura que representa un equipo de la liga
/// No tiene dependencias de Firebase ni de ninguna capa externa
struct Team {
    var nombre: String
    var ciudad: String
    var estadio: String
    var logo: String
    var partidosJugados: Int
    var partidosGanados: Int
    var partidosEmpatados: Int
    var partidosPerdidos: Int
    var golesFavor: Int
    var golesContra: Int
    var diferenciaGoles: Int
    var puntos: Int

    init(nombre: String = "Sin nombre",
         ciudad: String = "Sin ciudad",
         estadio: String = "Sin estadio",
         logo: String = "Sin logo",
         partidosJugados: Int = 0,
         partidosGanados: Int = 0,
         partidosEmpatados: Int = 0,
         partidosPerdidos: Int = 0,
         golesFavor: Int = 0,
         golesContra: Int = 0,
         diferenciaGoles: Int = 0,
         puntos: Int = 0) {
        self.nombre = nombre
        self.ciudad = ciudad
        self.estadio = estadio
        self.logo = logo
        self.partidosJugados = partidosJugados
        self.partidosGanados = partidosGanados
        self.partidosEmpatados = partidosEmpatados
        self.partidosPerdidos = partidosPerdidos
        self.golesFavor = golesFavor
        self.golesContra = golesContra
        self.diferenciaGoles = diferenciaGoles
        self.puntos = puntos
    }
}

// MARK: - Equatable
extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.nombre == rhs.nombre &&
               lhs.ciudad == rhs.ciudad
    }
}

// MARK: - Hashable
extension Team: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(nombre)
        hasher.combine(ciudad)
    }
}
