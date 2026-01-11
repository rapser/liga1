//
//  NewsRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener noticias
protocol NewsRepositoryProtocol {
    func fetchNews() -> AnyPublisher<[NewsItem], Error>
}
