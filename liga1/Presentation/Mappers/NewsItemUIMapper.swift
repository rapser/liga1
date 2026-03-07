//
//  NewsItemUIMapper.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Mapper para convertir entre NewsItem (Domain layer) y NewsItemUI (Presentation layer)
struct NewsItemUIMapper {

    /// Convierte una entidad de dominio NewsItem a un modelo de presentación NewsItemUI
    /// - Parameter domain: La entidad de dominio
    /// - Returns: El modelo de presentación
    static func toUI(from domain: NewsItem) -> NewsItemUI {
        return NewsItemUI(
            title: domain.title,
            imageUrl: domain.imageUrl,
            url: domain.url,
            source: domain.source,
            category: domain.category,
            publishedDate: domain.publishedDate
        )
    }

    /// Convierte múltiples entidades de dominio a modelos de presentación
    /// - Parameter domains: Array de entidades de dominio
    /// - Returns: Array de modelos de presentación
    static func toUI(from domains: [NewsItem]) -> [NewsItemUI] {
        return domains.map { toUI(from: $0) }
    }

    /// Convierte un modelo de presentación NewsItemUI a una entidad de dominio NewsItem
    /// - Parameter ui: El modelo de presentación
    /// - Returns: La entidad de dominio
    static func toDomain(from ui: NewsItemUI) -> NewsItem {
        return NewsItem(
            title: ui.title,
            imageUrl: ui.imageUrl,
            url: ui.url,
            source: ui.source,
            category: ui.category,
            publishedDate: ui.publishedDate
        )
    }
}
