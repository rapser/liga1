//
//  MatchDTO.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para Match desde Firestore (construcción manual en repositorio).
struct MatchDTO {
    let id: String?
    let equipoLocalId: String?
    let equipoVisitanteId: String?
    let fecha: Timestamp?
    let golesTeamA: Int?
    let golesTeamB: Int?
    let estado: String?
    let suspendido: Bool?
    let arbitro: String?
    let estadio: String?
    let capacidad: String?
    let canalesTV: [String]?
    let liveStats: MatchLiveStatsDTO?

    init(
        id: String? = nil,
        equipoLocalId: String?,
        equipoVisitanteId: String?,
        fecha: Timestamp?,
        golesTeamA: Int?,
        golesTeamB: Int?,
        estado: String?,
        suspendido: Bool?,
        arbitro: String? = nil,
        estadio: String? = nil,
        capacidad: String? = nil,
        canalesTV: [String]? = nil,
        liveStats: MatchLiveStatsDTO? = nil
    ) {
        self.id = id
        self.equipoLocalId = equipoLocalId
        self.equipoVisitanteId = equipoVisitanteId
        self.fecha = fecha
        self.golesTeamA = golesTeamA
        self.golesTeamB = golesTeamB
        self.estado = estado
        self.suspendido = suspendido
        self.arbitro = arbitro
        self.estadio = estadio
        self.capacidad = capacidad
        self.canalesTV = canalesTV
        self.liveStats = liveStats
    }
}

/// Sub-objeto opcional en Firestore para estadísticas comparativas.
struct MatchLiveStatsDTO: Equatable {
    let posesionLocal: Int?
    let posesionVisitante: Int?
    let rematesLocal: Int?
    let rematesVisitante: Int?
    let tirosAPuertaLocal: Int?
    let tirosAPuertaVisitante: Int?
    let cornersLocal: Int?
    let cornersVisitante: Int?
}
