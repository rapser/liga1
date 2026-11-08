//
//  TeamUI.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Modelo de presentación para Team con propiedades formateadas para la UI
struct TeamUI {
    let nombre: String
    let ciudad: String
    let estadio: String
    let logo: String
    let partidosJugados: Int
    let partidosGanados: Int
    let partidosEmpatados: Int
    let partidosPerdidos: Int
    let golesFavor: Int
    let golesContra: Int
    let diferenciaGoles: Int
    let puntos: Int
    var isFavorite: Bool = false

    // MARK: - Computed Properties for UI

    /// Porcentaje de victorias
    var porcentajeVictorias: Double {
        guard partidosJugados > 0 else { return 0.0 }
        return (Double(partidosGanados) / Double(partidosJugados)) * 100.0
    }

    /// Diferencia de goles formateada con signo
    var diferenciaGolesTexto: String {
        if diferenciaGoles >= 0 {
            return "+\(diferenciaGoles)"
        }
        return "\(diferenciaGoles)"
    }

    /// Información del equipo para mostrar
    var informacionCompleta: String {
        return "\(nombre) - \(ciudad)"
    }
}

// MARK: - Extensions
extension TeamUI: Identifiable {
    var id: String { nombre }
}

extension TeamUI: Equatable {
    static func == (lhs: TeamUI, rhs: TeamUI) -> Bool {
        return lhs.nombre == rhs.nombre && lhs.ciudad == rhs.ciudad
    }
}

extension TeamUI: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(nombre)
        hasher.combine(ciudad)
    }
}

// MARK: - Leyenda de sanciones

/// Fila de la leyenda de sanciones bajo la tabla acumulada.
struct SanctionNoteUI: Equatable {
    let teamName: String
    let points: Int
    let resolution: String

    /// "-10 pts"
    var pointsText: String {
        "\(points) pts"
    }

    static func make(from sanctions: [PointSanction], teams: [Team]) -> [SanctionNoteUI] {
        let nameByCode = Dictionary(teams.map { ($0.logo, $0.nombre) }, uniquingKeysWith: { first, _ in first })
        return sanctions
            .filter { $0.points < 0 }
            .map {
                SanctionNoteUI(
                    teamName: nameByCode[$0.teamCode] ?? $0.teamCode.uppercased(),
                    points: $0.points,
                    resolution: $0.resolution
                )
            }
            .sorted {
                $0.points != $1.points
                    ? $0.points < $1.points
                    : $0.teamName.localizedCaseInsensitiveCompare($1.teamName) == .orderedAscending
            }
    }
}
