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

// MARK: - Orden para listado de noticias

extension Array where Element == NewsCategory {
    /// Ordena categorías para el listado: destacado siempre primero; el resto por fecha (más reciente primero).
    /// - Parameter dateForCategory: Función que devuelve la fecha representativa de cada categoría (p. ej. fecha de la noticia más reciente).
    /// - Returns: Categorías ordenadas.
    public func sortedForNewsDisplay(dateForCategory: (NewsCategory) -> Date) -> [NewsCategory] {
        return sorted { category1, category2 in
            if category1 == .destacado { return true }
            if category2 == .destacado { return false }
            return dateForCategory(category1) > dateForCategory(category2)
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
