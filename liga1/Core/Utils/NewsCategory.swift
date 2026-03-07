//
//  NewsCategory.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Enum que representa las categorías de noticias disponibles en la aplicación
public enum NewsCategory: Equatable, Hashable {
    case destacado
    case partidos
    case fichajes
    case equipos
    case jugadores
    case tabla
    case estadisticas
    case other(String)

    /// Inicializa NewsCategory desde un String
    /// - Parameter rawValue: String que representa la categoría
    public init(rawValue: String) {
        switch rawValue.lowercased().trimmingCharacters(in: .whitespaces) {
        case "destacado":
            self = .destacado
        case "partidos":
            self = .partidos
        case "fichajes":
            self = .fichajes
        case "equipos":
            self = .equipos
        case "jugadores":
            self = .jugadores
        case "tabla":
            self = .tabla
        case "estadisticas", "estadísticas":
            self = .estadisticas
        default:
            self = .other(rawValue)
        }
    }

    /// Devuelve el valor String de la categoría para usar con Firestore
    public var rawValue: String {
        switch self {
        case .destacado:
            return "destacado"
        case .partidos:
            return "partidos"
        case .fichajes:
            return "fichajes"
        case .equipos:
            return "equipos"
        case .jugadores:
            return "jugadores"
        case .tabla:
            return "tabla"
        case .estadisticas:
            return "estadisticas"
        case .other(let value):
            return value
        }
    }

    /// Devuelve el nombre para mostrar en la UI (capitalizado)
    public var displayName: String {
        switch self {
        case .destacado:
            return "Destacado"
        case .partidos:
            return "Partidos"
        case .fichajes:
            return "Fichajes"
        case .equipos:
            return "Equipos"
        case .jugadores:
            return "Jugadores"
        case .tabla:
            return "Tabla"
        case .estadisticas:
            return "Estadísticas"
        case .other(let value):
            return value.isEmpty ? value : value.prefix(1).uppercased() + value.dropFirst().lowercased()
        }
    }
}

// MARK: - Codable

extension NewsCategory: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
