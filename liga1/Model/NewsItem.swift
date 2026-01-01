//
//  NewsItem.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import Foundation
import FirebaseFirestore

struct NewsItem {
    let title: String
    let imageUrl: String
    let url: String
    let periodico: String
    let categoria: String
    let destacada: Bool
    let fecha: Date
}

extension NewsItem {
    init?(from dict: [String: Any]) {
        guard let title = dict["title"] as? String,
              let imageUrl = dict["image"] as? String,
              let url = dict["url"] as? String,
              let periodico = dict["periodico"] as? String,
              let categoria = dict["categoria"] as? String,
              let destacada = dict["destacada"] as? Bool,
              let timestamp = dict["fecha"] as? Timestamp else {
            return nil
        }
        
        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.periodico = periodico
        self.categoria = categoria
        self.destacada = destacada
        self.fecha = timestamp.dateValue()
    }
}
