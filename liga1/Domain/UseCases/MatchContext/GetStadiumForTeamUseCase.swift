//
//  GetStadiumForTeamUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol GetStadiumForTeamUseCaseProtocol {
    /// Estadio local del partido a partir del código del equipo local.
    func execute(homeTeamCode: String) -> AnyPublisher<Stadium?, Error>
}

final class GetStadiumForTeamUseCase: GetStadiumForTeamUseCaseProtocol {

    private let repository: StadiumRepositoryProtocol

    init(repository: StadiumRepositoryProtocol) {
        self.repository = repository
    }

    func execute(homeTeamCode: String) -> AnyPublisher<Stadium?, Error> {
        let code = homeTeamCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return repository.fetchStadium(forHomeTeam: code)
    }
}
