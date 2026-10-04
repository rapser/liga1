//
//  Player.swift
//  liga1
//

import Foundation

/// Línea en la que juega un futbolista. El orden de `allCases` es el de la plantilla.
enum PlayerPosition: CaseIterable {
    case goalkeeper
    case defender
    case midfielder
    case forward

    /// Código con el que se guarda en `equipos/{code}/players` (`GK`, `DF`, `MF`, `FW`).
    init?(code: String) {
        switch code.uppercased() {
        case "GK": self = .goalkeeper
        case "DF": self = .defender
        case "MF": self = .midfielder
        case "FW": self = .forward
        default: return nil
        }
    }

    /// Título de sección en la pantalla de plantilla.
    var sectionTitle: String {
        switch self {
        case .goalkeeper: return "Porteros"
        case .defender: return "Defensas"
        case .midfielder: return "Mediocampistas"
        case .forward: return "Delanteros"
        }
    }
}

/// Futbolista de la plantilla de un equipo. Entidad de dominio pura.
struct Player: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let number: Int?
    let position: PlayerPosition
    let age: Int?
    let photoURL: URL?
    /// Atribución de la foto (p. ej. "Wikimedia Commons"). `nil` si no la exige.
    let photoCredit: String?
}
