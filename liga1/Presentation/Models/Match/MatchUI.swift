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
    let minutoActual: String?
    let golesDetalle: [MatchGoal]
    let tarjetasRojasDetalle: [MatchRedCard]
    let arbitro: String?
    let estadio: String?
    let capacidad: String?
    let canalesTV: [String]
    let liveStats: MatchLiveStats?
    let resumenYoutubeUrl: String?

    init(
        id: String,
        equipoLocalId: String? = nil,
        equipoVisitanteId: String? = nil,
        fecha: Date,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: Match.EstadoMatch = .pendiente,
        suspendido: Bool = false,
        minutoActual: String? = nil,
        golesDetalle: [MatchGoal] = [],
        tarjetasRojasDetalle: [MatchRedCard] = [],
        arbitro: String? = nil,
        estadio: String? = nil,
        capacidad: String? = nil,
        canalesTV: [String] = [],
        liveStats: MatchLiveStats? = nil,
        resumenYoutubeUrl: String? = nil
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
        self.minutoActual = minutoActual
        self.golesDetalle = golesDetalle
        self.tarjetasRojasDetalle = tarjetasRojasDetalle
        self.arbitro = arbitro
        self.estadio = estadio
        self.capacidad = capacidad
        self.canalesTV = canalesTV
        self.liveStats = liveStats
        self.resumenYoutubeUrl = resumenYoutubeUrl
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

extension MatchUI: Identifiable {}

extension MatchUI: Equatable {
    static func == (lhs: MatchUI, rhs: MatchUI) -> Bool {
        lhs.id == rhs.id &&
            lhs.fecha == rhs.fecha &&
            lhs.golesEquipoLocal == rhs.golesEquipoLocal &&
            lhs.golesEquipoVisitante == rhs.golesEquipoVisitante &&
            lhs.estado == rhs.estado &&
            lhs.suspendido == rhs.suspendido &&
            lhs.minutoActual == rhs.minutoActual &&
            lhs.golesDetalle == rhs.golesDetalle &&
            lhs.tarjetasRojasDetalle == rhs.tarjetasRojasDetalle &&
            lhs.arbitro == rhs.arbitro &&
            lhs.estadio == rhs.estadio &&
            lhs.capacidad == rhs.capacidad &&
            lhs.canalesTV == rhs.canalesTV &&
            lhs.liveStats == rhs.liveStats &&
            lhs.resumenYoutubeUrl == rhs.resumenYoutubeUrl
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
        hasher.combine(minutoActual)
        hasher.combine(golesDetalle)
        hasher.combine(tarjetasRojasDetalle)
        hasher.combine(resumenYoutubeUrl)
    }
}
