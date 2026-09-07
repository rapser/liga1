//
//  StadiumDTO.swift
//  liga1
//

import Foundation

/// DTO de `stadiums/{code}` en Firestore.
struct StadiumDTO: Codable {
    let name: String?
    let city: String?
    let region: String?
    let altitudeMsnm: Int?
    let lat: Double?
    let lng: Double?
    let capacity: Int?
    let dato: String?
    let homeTeamCodes: [String]?
}
