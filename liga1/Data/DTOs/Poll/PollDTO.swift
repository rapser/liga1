//
//  PollDTO.swift
//  liga1
//

import Foundation

/// `polls/{pollId}` en Firestore. Lo escribe el Admin web.
struct PollDTO: Codable {
    struct OptionDTO: Codable {
        let id: String?
        let texto: String?
    }

    let matchId: String?
    let jornadaId: String?
    let pregunta: String?
    let opciones: [OptionDTO]?
    let estado: String?
    /// `Timestamp` de Firestore → `Date` vía Codable.
    let cierraEn: Date?
    let creadoEn: Date?
    let numShards: Int?
}

/// `polls/{pollId}/shards/{n}` — contador distribuido.
struct PollShardDTO: Codable {
    let counts: [String: Int]?
}

/// `pollVotes/{pollId}/votes/{uid}` — voto del usuario.
struct PollVoteDTO: Codable {
    let opcionId: String?
}
