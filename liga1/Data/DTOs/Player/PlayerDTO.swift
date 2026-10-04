//
//  PlayerDTO.swift
//  liga1
//

import Foundation

/// DTO de `equipos/{code}/players/{playerId}` en Firestore.
struct PlayerDTO: Codable {
    let name: String?
    let shortName: String?
    let number: Int?
    /// `GK`, `DF`, `MF` o `FW`.
    let position: String?
    let age: Int?
    let photoURL: String?
    let photoCredit: String?
    let active: Bool?
}
