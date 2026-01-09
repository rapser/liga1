//
//  NewsItem.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import Foundation

/// Entidad de dominio pura que representa una noticia
/// No tiene dependencias de Firebase ni de ninguna capa externa
struct NewsItem {
    let title: String
    let imageUrl: String
    let url: String
    let source: String
    let category: NewsCategory
    let featured: Bool
    let publishedDate: Date

    init(title: String, imageUrl: String, url: String, source: String, category: NewsCategory, featured: Bool, publishedDate: Date) {
        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.source = source
        self.category = category
        self.featured = featured
        self.publishedDate = publishedDate
    }
}

// MARK: - Equatable
extension NewsItem: Equatable {
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        return lhs.title == rhs.title &&
               lhs.url == rhs.url &&
               lhs.publishedDate == rhs.publishedDate
    }
}

// MARK: - Hashable
extension NewsItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(url)
        hasher.combine(publishedDate)
    }
}
