//
//  Match.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation

/// Entidad de dominio para Match (sin dependencias de Firebase)
struct Match {
    let id: String
    let equipoLocalId: String?
    let equipoVisitanteId: String?
    let fecha: Date
    var golesEquipoLocal: Int
    var golesEquipoVisitante: Int
    var estado: EstadoMatch
    var suspendido: Bool

    init(
        id: String,
        equipoLocalId: String? = nil,
        equipoVisitanteId: String? = nil,
        fecha: Date,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: EstadoMatch = .pendiente,
        suspendido: Bool = false
    ) {
        // Si el id viene vacío pero tenemos los IDs de equipos, construimos el id
        if id.isEmpty, let localId = equipoLocalId, let visitanteId = equipoVisitanteId {
            self.id = "\(localId)_\(visitanteId)"
            self.equipoLocalId = localId
            self.equipoVisitanteId = visitanteId
        } else {
            self.id = id
            // Si no vienen los IDs de equipos pero tenemos el id, los extraemos
            if equipoLocalId == nil || equipoVisitanteId == nil {
                let components = id.split(separator: "_")
                self.equipoLocalId = components.first.map(String.init)
                self.equipoVisitanteId = components.count >= 2 ? String(components[1]) : nil
            } else {
                self.equipoLocalId = equipoLocalId
                self.equipoVisitanteId = equipoVisitanteId
            }
        }
        
        self.fecha = fecha
        self.golesEquipoLocal = golesEquipoLocal
        self.golesEquipoVisitante = golesEquipoVisitante
        self.estado = estado
        self.suspendido = suspendido
    }

    // Enum para estado del partido
    enum EstadoMatch: String, Codable {
        case pendiente
        case enJuego
        case finalizado
        case anulado
        case suspendido
    }
}

// MARK: - Extensions
extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.id == rhs.id &&
               lhs.fecha == rhs.fecha &&
               lhs.golesEquipoLocal == rhs.golesEquipoLocal &&
               lhs.golesEquipoVisitante == rhs.golesEquipoVisitante &&
               lhs.estado == rhs.estado &&
               lhs.suspendido == rhs.suspendido
    }
}

extension Match: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fecha)
        hasher.combine(golesEquipoLocal)
        hasher.combine(golesEquipoVisitante)
        hasher.combine(estado)
        hasher.combine(suspendido)
    }
}
