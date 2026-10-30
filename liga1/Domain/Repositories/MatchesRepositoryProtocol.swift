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
    /// `false` mientras los partidos de la jornada solo vienen de la caché local; `true` cuando el
    /// servidor los confirmó. Sirve para no mostrar como real un marcador que pudo cambiar.
    func observeMatchesConfirmed(for jornadaId: String) -> AnyPublisher<Bool, Never>
    /// Fuerza una lectura desde el servidor y la empuja al publisher de `observeMatches`.
    /// El listener en tiempo real puede quedar desincronizado tras un ciclo largo de
    /// background/foreground; esto corrige el valor visible sin esperar a que se reconecte.
    /// `completion` recibe `true` si la lectura del servidor terminó bien (la caché persistente
    /// queda actualizada); sirve para cerrar el `completionHandler` de un push silencioso.
    func refreshMatches(for jornadaId: String, completion: ((Bool) -> Void)?)
}

extension FetchMatchesRepositoryProtocol {
    func refreshMatches(for jornadaId: String) {
        refreshMatches(for: jornadaId, completion: nil)
    }
}

/// Alias para compatibilidad con código existente
typealias MatchesRepositoryProtocol = FetchMatchesRepositoryProtocol
