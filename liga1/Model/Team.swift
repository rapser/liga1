//
//  Team.swift
//  liga1
//
//  Created by miguel tomairo on 30/08/24.
//

import Foundation

struct Team {
    let nombre: String
    let ciudad: String
    let estadio: String

    init(nombre: String = "Sin nombre",
         ciudad: String = "Sin ciudad",
         estadio: String = "Sin estadio") {
        self.nombre = nombre
        self.ciudad = ciudad
        self.estadio = estadio
    }
}
