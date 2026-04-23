//
//  MatchUI.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation

/// Modelo de presentación para Match con propiedades formateadas para la UI
struct MatchUI {
    let id: String
    let equipoLocalId: String?
    let equipoVisitanteId: String?
    let fecha: Date
    var golesEquipoLocal: Int
    var golesEquipoVisitante: Int
    var estado: Match.EstadoMatch
    var suspendido: Bool

    init(
        id: String,
        equipoLocalId: String? = nil,
        equipoVisitanteId: String? = nil,
        fecha: Date,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: Match.EstadoMatch = .pendiente,
        suspendido: Bool = false
    ) {
        self.id = id
        if let localId = equipoLocalId {
            self.equipoLocalId = localId
        } else {
            let components = id.split(separator: "_")
            self.equipoLocalId = components.first.map(String.init)
        }

        if let visitanteId = equipoVisitanteId {
            self.equipoVisitanteId = visitanteId
        } else {
            let components = id.split(separator: "_")
            self.equipoVisitanteId = components.count >= 2 ? String(components[1]) : nil
        }

        self.fecha = fecha
        self.golesEquipoLocal = golesEquipoLocal
        self.golesEquipoVisitante = golesEquipoVisitante
        self.estado = estado
        self.suspendido = suspendido
    }

    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: fecha)
    }

    var marcador: String {
        return "\(golesEquipoLocal) - \(golesEquipoVisitante)"
    }

    var estadoTexto: String {
        switch estado {
        case .pendiente:
            return "Próximo"
        case .envivo:
            return "En Vivo"
        case .finalizado:
            return "Finalizado"
        case .anulado:
            return "Anulado"
        case .suspendido:
            return "Suspendido"
        }
    }

    var estaEnJuego: Bool {
        return estado == .envivo
    }

    var haFinalizado: Bool {
        return estado == .finalizado
    }
}

// MARK: - Extensions
extension MatchUI: Identifiable {}

extension MatchUI: Equatable {
    static func == (lhs: MatchUI, rhs: MatchUI) -> Bool {
        return lhs.id == rhs.id &&
               lhs.fecha == rhs.fecha &&
               lhs.golesEquipoLocal == rhs.golesEquipoLocal &&
               lhs.golesEquipoVisitante == rhs.golesEquipoVisitante &&
               lhs.estado == rhs.estado &&
               lhs.suspendido == rhs.suspendido
    }
}

extension MatchUI: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fecha)
        hasher.combine(golesEquipoLocal)
        hasher.combine(golesEquipoVisitante)
        hasher.combine(estado)
        hasher.combine(suspendido)
    }
}
