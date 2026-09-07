//
//  RefereeDTO.swift
//  liga1
//

import Foundation

/// DTO de `referees/{id}` en Firestore.
struct RefereeDTO: Codable {
    let fullName: String?
    let federation: String?
    let nationality: String?
    let photoURL: String?
    let career: CareerDTO?

    struct CareerDTO: Codable {
        let matches: Int?
        let penaltiesPerGame: Double?
        let yellowPerGame: Double?
        let redPerGame: Double?
    }
}
