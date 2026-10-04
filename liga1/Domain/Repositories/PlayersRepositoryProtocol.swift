//
//  PlayersRepositoryProtocol.swift
//  liga1
//

import Foundation
import Combine

/// Provee la plantilla de un equipo.
protocol PlayersRepositoryProtocol {
    /// Jugadores activos de `equipos/{teamId}/players`. `teamId` es el código del equipo ("ali", "uni"...).
    func fetchSquad(teamId: String) -> AnyPublisher<[Player], Error>
}
