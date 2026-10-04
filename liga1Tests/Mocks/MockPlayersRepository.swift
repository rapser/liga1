// MockPlayersRepository.swift
// liga1Tests

import Combine
@testable import liga1

final class MockPlayersRepository: PlayersRepositoryProtocol {

    var fetchResult: Result<[Player], Error> = .success([])
    var fetchCallCount = 0
    private(set) var lastTeamId: String?

    func fetchSquad(teamId: String) -> AnyPublisher<[Player], Error> {
        fetchCallCount += 1
        lastTeamId = teamId
        switch fetchResult {
        case .success(let players):
            return Just(players).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
