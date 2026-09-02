//
//  Stadium.swift
//  liga1
//

import Foundation

/// Estadio de la Liga 1 (entidad de dominio pura, sin dependencias de Firebase).
struct Stadium {
    let code: String
    let name: String
    let city: String
    let region: String
    let altitudeMsnm: Int
    let lat: Double
    let lng: Double
    let capacity: Int
    /// Frase histórica corta para el panel "Sabor Local"; puede faltar.
    let dato: String?

    init(
        code: String,
        name: String,
        city: String = "",
        region: String = "",
        altitudeMsnm: Int = 0,
        lat: Double = 0,
        lng: Double = 0,
        capacity: Int = 0,
        dato: String? = nil
    ) {
        self.code = code
        self.name = name
        self.city = city
        self.region = region
        self.altitudeMsnm = altitudeMsnm
        self.lat = lat
        self.lng = lng
        self.capacity = capacity
        self.dato = dato
    }
}

// MARK: - Reglas de dominio

extension Stadium {
    /// Umbral a partir del cual la cancha se considera "de altura" en el fútbol peruano.
    static let alturaThresholdMsnm = 2000

    var esDeAltura: Bool { altitudeMsnm >= Stadium.alturaThresholdMsnm }
}

// MARK: - Equatable / Hashable

extension Stadium: Equatable {
    static func == (lhs: Stadium, rhs: Stadium) -> Bool { lhs.code == rhs.code }
}

extension Stadium: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(code) }
}
