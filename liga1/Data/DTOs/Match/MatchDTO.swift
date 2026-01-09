//
//  MatchDTO.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para Match desde Firestore
struct MatchDTO: Codable {
    @DocumentID var id: String?
    let equipoLocalId: String?
    let equipoVisitanteId: String?
    let fecha: Timestamp?
    let golesTeamA: Int?
    let golesTeamB: Int?
    let estado: String?
    let suspendido: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case equipoLocalId
        case equipoVisitanteId
        case fecha
        case golesTeamA
        case golesTeamB
        case estado
        case suspendido
    }

    init(id: String? = nil, equipoLocalId: String?, equipoVisitanteId: String?, fecha: Timestamp?, golesTeamA: Int?, golesTeamB: Int?, estado: String?, suspendido: Bool?) {
        self.id = id
        self.equipoLocalId = equipoLocalId
        self.equipoVisitanteId = equipoVisitanteId
        self.fecha = fecha
        self.golesTeamA = golesTeamA
        self.golesTeamB = golesTeamB
        self.estado = estado
        self.suspendido = suspendido
    }
}
