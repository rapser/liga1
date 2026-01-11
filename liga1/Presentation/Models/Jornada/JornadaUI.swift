//
//  JornadaUI.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Modelo de presentación para Jornada
/// Contiene propiedades formateadas y listas para mostrar en la UI
struct JornadaUI {
    let id: String
    let torneo: String
    let numero: Int
    let mostrar: Bool
    let fechaInicio: Date

    // MARK: - Computed Properties for UI

    /// Texto formateado para mostrar el número de jornada
    var numeroTexto: String {
        return "Jornada \(numero)"
    }

    /// Texto formateado para mostrar el torneo con número
    var descripcion: String {
        return "\(torneo.capitalized) - Jornada \(numero)"
    }

    /// Fecha formateada para mostrar en la UI
    var fechaInicioFormateada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: fechaInicio)
    }

    init(id: String, torneo: String, numero: Int, mostrar: Bool, fechaInicio: Date) {
        self.id = id
        self.torneo = torneo
        self.numero = numero
        self.mostrar = mostrar
        self.fechaInicio = fechaInicio
    }
}

// MARK: - Identifiable
extension JornadaUI: Identifiable {}

// MARK: - Equatable
extension JornadaUI: Equatable {
    static func == (lhs: JornadaUI, rhs: JornadaUI) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension JornadaUI: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
