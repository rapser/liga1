//
//  NewsItemDTO.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para NewsItem desde Firestore
struct NewsItemDTO: Codable {
    let id: String?
    let title: String?
    let image: String?
    let url: String?
    let periodico: String?
    let categoria: String?
    let fecha: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case url
        case periodico
        case categoria
        case fecha
    }

    init(id: String? = nil, title: String?, image: String?, url: String?, periodico: String?, categoria: String?, fecha: Timestamp?) {
        self.id = id
        self.title = title
        self.image = image
        self.url = url
        self.periodico = periodico
        self.categoria = categoria
        self.fecha = fecha
    }
}
