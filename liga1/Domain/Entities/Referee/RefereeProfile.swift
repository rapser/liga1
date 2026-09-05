//
//  RefereeProfile.swift
//  liga1
//

import Foundation

/// Ficha de árbitro para el "Termómetro Arbitral" (entidad de dominio pura).
struct RefereeProfile {

    struct Career {
        let matches: Int
        let penaltiesPerGame: Double
        let yellowPerGame: Double
        let redPerGame: Double
    }

    let id: String
    let fullName: String
    let federation: String
    let nationality: String
    let photoURL: String?
    /// Estadísticas de carrera; `nil` mientras no exista un feed que las alimente.
    let career: Career?

    init(
        id: String,
        fullName: String,
        federation: String = "",
        nationality: String = "",
        photoURL: String? = nil,
        career: Career? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.federation = federation
        self.nationality = nationality
        self.photoURL = photoURL
        self.career = career
    }
}

// MARK: - Equatable / Hashable

extension RefereeProfile: Equatable {
    static func == (lhs: RefereeProfile, rhs: RefereeProfile) -> Bool { lhs.id == rhs.id }
}

extension RefereeProfile: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
