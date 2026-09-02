//
//  StadiumRepositoryProtocol.swift
//  liga1
//

import Foundation
import Combine

/// Provee el estadio local de un partido a partir del código de equipo.
protocol StadiumRepositoryProtocol {
    /// Estadio cuyo `homeTeamCodes` contiene `teamCode`. `nil` si no hay match.
    func fetchStadium(forHomeTeam teamCode: String) -> AnyPublisher<Stadium?, Error>
}
