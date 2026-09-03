//
//  GetMatchWeatherUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol GetMatchWeatherUseCaseProtocol {
    /// Clima estimado para la sede del partido (Sabor Local).
    func execute(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error>
}

final class GetMatchWeatherUseCase: GetMatchWeatherUseCaseProtocol {

    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error> {
        let jornada = jornadaId.trimmingCharacters(in: .whitespacesAndNewlines)
        let match = matchId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !jornada.isEmpty, !match.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return repository.fetchWeather(jornadaId: jornada, matchId: match)
    }
}
