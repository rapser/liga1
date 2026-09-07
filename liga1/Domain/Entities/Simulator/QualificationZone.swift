//
//  QualificationZone.swift
//  liga1
//

import Foundation

/// Zona de la tabla en la que cae un equipo según su posición proyectada.
enum QualificationZone: Equatable {
    case libertadores          // fase de grupos
    case libertadoresPrevia    // fase previa
    case sudamericana
    case descenso
    case none

    var displayName: String {
        switch self {
        case .libertadores: return "Libertadores (grupos)"
        case .libertadoresPrevia: return "Libertadores (previa)"
        case .sudamericana: return "Sudamericana"
        case .descenso: return "Descenso"
        case .none: return "—"
        }
    }

    var esPositiva: Bool {
        self == .libertadores || self == .libertadoresPrevia || self == .sudamericana
    }
}

/// Bandas de posición para clasificar a copas y marcar el descenso.
///
/// Aproximación ilustrativa: los cupos reales a Libertadores/Sudamericana dependen
/// de campeones de torneo, la Copa Perú y desempates/playoffs. El simulador lo indica.
struct QualificationRules: Equatable {
    /// Posiciones (1-based) que van a Libertadores fase de grupos.
    let libertadores: ClosedRange<Int>
    /// Posiciones a Libertadores fase previa. `nil` si no aplica.
    let libertadoresPrevia: ClosedRange<Int>?
    /// Posiciones a Copa Sudamericana.
    let sudamericana: ClosedRange<Int>
    /// Cantidad de últimos puestos que descienden.
    let descensoUltimos: Int

    /// Default Liga 1 (tabla de 18, criterio acumulado).
    static let liga1 = QualificationRules(
        libertadores: 1...2,
        libertadoresPrevia: 3...4,
        sudamericana: 5...7,
        descensoUltimos: 3
    )
}
