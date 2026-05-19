// MockTeamsRepository.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockTeamsRepository: TeamsRepositoryProtocol {

    var fetchResult: Result<[Team], Error> = .success([])
    var fetchCallCount = 0
    var lastTorneoRequested: TorneoType?

    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        fetchCallCount += 1
        lastTorneoRequested = torneo
        switch fetchResult {
        case .success(let teams):
            return Just(teams).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
