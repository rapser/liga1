//
//  WeatherRepositoryProtocol.swift
//  liga1
//

import Foundation
import Combine

/// Provee el clima estimado de un partido (sub-objeto `clima` del documento del partido).
protocol WeatherRepositoryProtocol {
    /// Clima de `jornadas/{jornadaId}/matches/{matchId}`. `nil` si el partido no
    /// tiene el sub-objeto `clima` todavía (el Admin aún no lo generó).
    func fetchWeather(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error>
}
