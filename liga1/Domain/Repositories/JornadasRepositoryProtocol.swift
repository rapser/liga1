//
//  JornadasRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener jornadas activas
protocol JornadasRepositoryProtocol {
    /// Obtiene jornadas activas una sola vez (no reactivo)
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
    
    /// Observa cambios en jornadas activas en tiempo real (reactivo)
    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never>
}
