//
//  PlayerMapper.swift
//  liga1
//

import Foundation

/// Convierte `PlayerDTO` (Data) → `Player` (Domain).
struct PlayerMapper {

    /// `nil` si el documento no sirve para mostrarse (sin nombre o con posición desconocida).
    static func toDomain(from dto: PlayerDTO, id: String) -> Player? {
        guard let name = dto.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
              let position = dto.position.flatMap(PlayerPosition.init(code:)) else {
            return nil
        }

        return Player(
            id: id,
            name: name,
            shortName: dto.shortName?.isEmpty == false ? dto.shortName ?? name : name,
            number: dto.number,
            position: position,
            age: dto.age,
            photoURL: validPhotoURL(dto.photoURL),
            photoCredit: dto.photoCredit?.isEmpty == false ? dto.photoCredit : nil
        )
    }

    /// Solo https: ATS bloquea http y no queremos cargar fotos de orígenes arbitrarios sin cifrar.
    private static func validPhotoURL(_ value: String?) -> URL? {
        guard let value, let url = URL(string: value), url.scheme?.lowercased() == "https" else {
            return nil
        }
        return url
    }
}
