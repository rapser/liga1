//
//  NewsItemDTO.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para NewsItem desde Firestore
struct NewsItemDTO: Codable {
    @DocumentID var id: String?
    let titulo: String?
    let descripcion: String?
    let imageUrl: String?
    let fecha: Timestamp?
    let destacado: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case descripcion
        case imageUrl
        case fecha
        case destacado
    }
}
