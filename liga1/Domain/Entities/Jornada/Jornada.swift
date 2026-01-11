//
//  Jornada.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Entidad de dominio pura que representa una jornada de la liga
/// No tiene dependencias de Firebase ni de ninguna capa externa
struct Jornada {
    let id: String
    let torneo: String
    let numero: Int
    let mostrar: Bool
    let fechaInicio: Date

    init(id: String, torneo: String, numero: Int, mostrar: Bool, fechaInicio: Date) {
        self.id = id
        self.torneo = torneo
        self.numero = numero
        self.mostrar = mostrar
        self.fechaInicio = fechaInicio
    }
}

// MARK: - Equatable
extension Jornada: Equatable {
    static func == (lhs: Jornada, rhs: Jornada) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Jornada: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
