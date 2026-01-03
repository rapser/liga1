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
    let source: String
    let category: String
    let featured: Bool
    let publishedDate: Date

    init(title: String, imageUrl: String, url: String, source: String, category: String, featured: Bool, publishedDate: Date) {
        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.source = source
        self.category = category
        self.featured = featured
        self.publishedDate = publishedDate
    }
}

extension NewsItem {
    init?(from dict: [String: Any]) {
        guard let title = dict["title"] as? String,
              let imageUrl = dict["image"] as? String,
              let url = dict["url"] as? String,
              let source = dict["periodico"] as? String,
              let category = dict["categoria"] as? String,
              let featured = dict["destacada"] as? Bool,
              let timestamp = dict["fecha"] as? Timestamp else {
            return nil
        }

        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.source = source
        self.category = category
        self.featured = featured
        self.publishedDate = timestamp.dateValue()
    }
}
