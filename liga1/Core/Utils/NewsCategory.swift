//
//  NewsCategory.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Enum que representa las categorías de noticias disponibles en la aplicación
public enum NewsCategory: Equatable, Hashable {
    case liga1
    case seleccion
    case internacional
    case other(String)

    /// Inicializa NewsCategory desde un String
    /// - Parameter rawValue: String que representa la categoría
    public init(rawValue: String) {
        switch rawValue.lowercased() {
        case "liga 1", "liga1":
            self = .liga1
        case "selección", "seleccion":
            self = .seleccion
        case "internacional":
            self = .internacional
        default:
            self = .other(rawValue)
        }
    }

    /// Devuelve el valor String de la categoría para usar con Firestore
    public var rawValue: String {
        switch self {
        case .liga1:
            return "Liga 1"
        case .seleccion:
            return "Selección"
        case .internacional:
            return "Internacional"
        case .other(let value):
            return value
        }
    }

    /// Devuelve el nombre para mostrar en la UI
    public var displayName: String {
        return rawValue
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
