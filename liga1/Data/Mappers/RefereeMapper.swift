//
//  RefereeMapper.swift
//  liga1
//

import Foundation

/// Convierte `RefereeDTO` (Data) → `RefereeProfile` (Domain).
struct RefereeMapper {
    static func toDomain(from dto: RefereeDTO, id: String) -> RefereeProfile {
        let career: RefereeProfile.Career?
        if let c = dto.career, let matches = c.matches, matches > 0 {
            career = RefereeProfile.Career(
                matches: matches,
                penaltiesPerGame: c.penaltiesPerGame ?? 0,
                yellowPerGame: c.yellowPerGame ?? 0,
                redPerGame: c.redPerGame ?? 0
            )
        } else {
            career = nil
        }
        return RefereeProfile(
            id: id,
            fullName: dto.fullName ?? id,
            federation: dto.federation ?? "",
            nationality: dto.nationality ?? "",
            photoURL: dto.photoURL?.isEmpty == false ? dto.photoURL : nil,
            career: career
        )
    }
}
