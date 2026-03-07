//
//  NewsItemUI.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Modelo de presentación para NewsItem con propiedades formateadas para la UI
struct NewsItemUI {
    let title: String
    let imageUrl: String
    let url: String
    let source: String
    let category: NewsCategory
    let publishedDate: Date

    // MARK: - Computed Properties for UI

    /// Fecha formateada para mostrar en la UI
    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: publishedDate)
    }

    /// Fecha formateada solo con fecha (sin hora)
    var fechaSoloTexto: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: publishedDate)
    }

    /// URL de la imagen como URL opcional
    var imageURL: URL? {
        return URL(string: imageUrl)
    }

    /// URL de la noticia como URL opcional
    var newsURL: URL? {
        return URL(string: url)
    }

    /// Título truncado para mostrar en listas
    func tituloTruncado(maxLength: Int = 100) -> String {
        guard title.count > maxLength else { return title }
        return String(title.prefix(maxLength)) + "..."
    }

    /// Categoría formateada para mostrar
    var categoriaTexto: String {
        return category.displayName
    }

    /// Indica si la noticia pertenece a la categoría Destacado (para layout destacado en la UI)
    var esDestacada: Bool {
        return category == .destacado
    }
}

// MARK: - Extensions
extension NewsItemUI: Identifiable {
    var id: String {
        return "\(title)_\(publishedDate.timeIntervalSince1970)"
    }
}

extension NewsItemUI: Equatable {
    static func == (lhs: NewsItemUI, rhs: NewsItemUI) -> Bool {
        return lhs.title == rhs.title &&
               lhs.url == rhs.url &&
               lhs.publishedDate == rhs.publishedDate
    }
}

extension NewsItemUI: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(url)
        hasher.combine(publishedDate)
    }
}
