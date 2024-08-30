//
//  Equipo.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation

struct Match {
    let nombre: String
    let ciudad: String
    let estadio: String
    let logo: String
    let partidosJugados: Int
    let partidosGanados: Int
    let partidosEmpatados: Int
    let partidosPerdidos: Int
    let golesFavor: Int
    let golesContra: Int
    let diferenciaGoles: Int
    let puntos: Int

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
