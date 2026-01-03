//
//  MatchDTO.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
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
}
