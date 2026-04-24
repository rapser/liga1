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
    /// Instante del partido; en datos se usa hora Perú (UTC−5 / PET).
    let fecha: Date
    var golesEquipoLocal: Int
    var golesEquipoVisitante: Int
    var estado: EstadoMatch
    var suspendido: Bool
    let arbitro: String?
    let estadio: String?
    let capacidad: String?
    let canalesTV: [String]
    let liveStats: MatchLiveStats?

    init(
        id: String,
        equipoLocalId: String? = nil,
        equipoVisitanteId: String? = nil,
        fecha: Date,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: EstadoMatch = .pendiente,
        suspendido: Bool = false,
        arbitro: String? = nil,
        estadio: String? = nil,
        capacidad: String? = nil,
        canalesTV: [String] = [],
        liveStats: MatchLiveStats? = nil
    ) {
        if id.isEmpty, let localId = equipoLocalId, let visitanteId = equipoVisitanteId {
            self.id = "\(localId)_\(visitanteId)"
            self.equipoLocalId = localId
            self.equipoVisitanteId = visitanteId
        } else {
            self.id = id
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
        self.arbitro = arbitro
        self.estadio = estadio
        self.capacidad = capacidad
        self.canalesTV = canalesTV
        self.liveStats = liveStats
    }

    enum EstadoMatch: String, Codable {
        case pendiente
        case envivo
        case finalizado
        case anulado
        case suspendido
    }
}

extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id &&
            lhs.fecha == rhs.fecha &&
            lhs.golesEquipoLocal == rhs.golesEquipoLocal &&
            lhs.golesEquipoVisitante == rhs.golesEquipoVisitante &&
            lhs.estado == rhs.estado &&
            lhs.suspendido == rhs.suspendido &&
            lhs.arbitro == rhs.arbitro &&
            lhs.estadio == rhs.estadio &&
            lhs.capacidad == rhs.capacidad &&
            lhs.canalesTV == rhs.canalesTV &&
            lhs.liveStats == rhs.liveStats
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
