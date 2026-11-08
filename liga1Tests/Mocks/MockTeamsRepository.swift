// MockTeamsRepository.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockTeamsRepository: TeamsRepositoryProtocol {

    var fetchResult: Result<[Team], Error> = .success([])
    var fetchCallCount = 0
    var invalidateCacheCallCount = 0
    var lastTorneoRequested: TorneoType?
    var lastInvalidatedTorneo: TorneoType??   // nil = not called; .some(nil) = invalidate all
    var pointSanctions: [PointSanction] = []
    var observePointSanctionsCallCount = 0
    var observedTeams: [TorneoType: [Team]] = [:]
    var observedTorneos: [TorneoType] = []
    var refreshedTorneos: [TorneoType]?
    var refreshResult = true

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

    func observeTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Never> {
        observedTorneos.append(torneo)
        return Just(observedTeams[torneo] ?? []).eraseToAnyPublisher()
    }

    func refreshStandings(for torneos: [TorneoType], completion: @escaping (Bool) -> Void) {
        refreshedTorneos = torneos
        completion(refreshResult)
    }

    func observePointSanctions() -> AnyPublisher<[PointSanction], Never> {
        observePointSanctionsCallCount += 1
        return Just(pointSanctions).eraseToAnyPublisher()
    }

    func invalidateCache(for torneo: TorneoType?) {
        invalidateCacheCallCount += 1
        lastInvalidatedTorneo = torneo
    }
}
