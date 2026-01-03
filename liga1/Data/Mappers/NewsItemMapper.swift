//
//  NewsItemMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre NewsItemDTO (Data Layer) y NewsItem (Domain Layer)
struct NewsItemMapper {

    /// Convierte NewsItemDTO a NewsItem (Domain Model)
    static func toDomain(from dto: NewsItemDTO) -> NewsItem {
        return NewsItem(
            title: dto.title ?? "",
            imageUrl: dto.image ?? "",
            url: dto.url ?? "",
            periodico: dto.periodico ?? "",
            categoria: dto.categoria ?? "",
            destacada: dto.destacada ?? false,
            fecha: dto.fecha?.dateValue() ?? Date()
        )
    }

    /// Convierte NewsItem (Domain Model) a NewsItemDTO
    static func toDTO(from domain: NewsItem) -> NewsItemDTO {
        return NewsItemDTO(
            id: nil,
            title: domain.title,
            image: domain.imageUrl,
            url: domain.url,
            periodico: domain.periodico,
            categoria: domain.categoria,
            destacada: domain.destacada,
            fecha: Timestamp(date: domain.fecha)
        )
    }

    /// Convierte array de NewsItemDTO a array de NewsItem
    static func toDomainArray(from dtos: [NewsItemDTO]) -> [NewsItem] {
        return dtos.map { toDomain(from: $0) }
    }
}
