//
//  MatchesRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener partidos
protocol FetchMatchesRepositoryProtocol {
    func fetchMatches(for jornadaId: String) -> AnyPublisher<[Match], Error>
    func observeMatches(for jornadaId: String) -> AnyPublisher<[Match], Never>
}

/// Alias para compatibilidad con código existente
typealias MatchesRepositoryProtocol = FetchMatchesRepositoryProtocol
