//
//  NewsItemMapper.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Mapper para convertir entre NewsItemDTO (Data Layer) y NewsItem (Domain Layer)
struct NewsItemMapper {

    /// Convierte NewsItemDTO a NewsItem (Domain Model)
    static func toDomain(from dto: NewsItemDTO) -> NewsItem {
        return NewsItem(
            id: dto.id,
            titulo: dto.titulo ?? "",
            descripcion: dto.descripcion ?? "",
            imageUrl: dto.imageUrl,
            fecha: dto.fecha?.dateValue(),
            destacado: dto.destacado ?? false
        )
    }

    /// Convierte NewsItem (Domain Model) a NewsItemDTO
    static func toDTO(from domain: NewsItem) -> NewsItemDTO {
        return NewsItemDTO(
            id: domain.id,
            titulo: domain.titulo,
            descripcion: domain.descripcion,
            imageUrl: domain.imageUrl,
            fecha: domain.fecha != nil ? Timestamp(date: domain.fecha!) : nil,
            destacado: domain.destacado
        )
    }

    /// Convierte array de NewsItemDTO a array de NewsItem
    static func toDomainArray(from dtos: [NewsItemDTO]) -> [NewsItem] {
        return dtos.map { toDomain(from: $0) }
    }
}
