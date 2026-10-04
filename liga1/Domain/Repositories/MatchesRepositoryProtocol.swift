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
    /// Fuerza una lectura desde el servidor y la empuja al publisher de `observeMatches`.
    /// El listener en tiempo real puede quedar desincronizado tras un ciclo largo de
    /// background/foreground; esto corrige el valor visible sin esperar a que se reconecte.
    func refreshMatches(for jornadaId: String)
}

/// Alias para compatibilidad con código existente
typealias MatchesRepositoryProtocol = FetchMatchesRepositoryProtocol
