//
//  StadiumMapper.swift
//  liga1
//

import Foundation

/// Convierte `StadiumDTO` (Data) ⇄ `Stadium` (Domain).
struct StadiumMapper {
    static func toDomain(from dto: StadiumDTO, code: String) -> Stadium {
        Stadium(
            code: code,
            name: dto.name ?? "",
            city: dto.city ?? "",
            region: dto.region ?? "",
            altitudeMsnm: dto.altitudeMsnm ?? 0,
            lat: dto.lat ?? 0,
            lng: dto.lng ?? 0,
            capacity: dto.capacity ?? 0,
            dato: dto.dato?.isEmpty == false ? dto.dato : nil
        )
    }
}
