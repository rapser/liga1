//
//  NewsItemMapper.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre NewsItemDTO (Data Layer) y NewsItem (Domain Layer)
struct NewsItemMapper {

    /// Convierte NewsItemDTO a NewsItem (Domain Model)
    static func toDomain(from dto: NewsItemDTO) -> NewsItem {
        let categoryString = dto.categoria ?? ""
        let category = NewsCategory(rawValue: categoryString)

        return NewsItem(
            title: dto.title ?? "",
            imageUrl: dto.image ?? "",
            url: dto.url ?? "",
            source: dto.periodico ?? "",
            category: category,
            featured: dto.destacada ?? false,
            publishedDate: dto.fecha?.dateValue() ?? Date()
        )
    }

    /// Convierte NewsItem (Domain Model) a NewsItemDTO
    static func toDTO(from domain: NewsItem) -> NewsItemDTO {
        return NewsItemDTO(
            id: nil,
            title: domain.title,
            image: domain.imageUrl,
            url: domain.url,
            periodico: domain.source,
            categoria: domain.category.rawValue,
            destacada: domain.featured,
            fecha: Timestamp(date: domain.publishedDate)
        )
    }

    /// Convierte array de NewsItemDTO a array de NewsItem
    static func toDomain(from dtos: [NewsItemDTO]) -> [NewsItem] {
        return dtos.map { toDomain(from: $0) }
    }
}
