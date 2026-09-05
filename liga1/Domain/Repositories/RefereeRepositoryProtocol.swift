//
//  RefereeRepositoryProtocol.swift
//  liga1
//

import Foundation
import Combine

/// Provee la ficha de un árbitro por su id (slug del nombre).
protocol RefereeRepositoryProtocol {
    /// Ficha en `referees/{refereeId}`. `nil` si el árbitro no está catalogado.
    func fetchReferee(id refereeId: String) -> AnyPublisher<RefereeProfile?, Error>
}
