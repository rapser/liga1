// MockFavoritesService.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockFavoritesService: FavoritesServiceProtocol {

    // MARK: - Toggle
    var toggleResult: Result<Bool, Error> = .success(true)
    var toggleCallCount = 0
    var lastToggledTeamId: String?

    // MARK: - Fetch
    var fetchResult: Result<Void, Error> = .success(())
    var fetchCallCount = 0

    // MARK: - Observe
    private let observeSubject = CurrentValueSubject<Set<String>, Never>([])
    var observeCallCount = 0

    // MARK: - isFavorite / getAll / getCurrent (stubs)
    var isFavoriteResult = false
    var getAllResult: [String] = []
    var currentFavorites: Set<String> = []

    func toggleFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Error> {
        toggleCallCount += 1
        lastToggledTeamId = teamId
        switch toggleResult {
        case .success(let added):
            return Just(added).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func fetchFavoriteTeams() -> AnyPublisher<Void, Error> {
        fetchCallCount += 1
        switch fetchResult {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func observeFavoriteTeams() -> AnyPublisher<Set<String>, Never> {
        observeCallCount += 1
        return observeSubject.eraseToAnyPublisher()
    }

    func isFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Never> {
        Just(isFavoriteResult).eraseToAnyPublisher()
    }

    func getAllFavoriteTeams() -> AnyPublisher<[String], Never> {
        Just(getAllResult).eraseToAnyPublisher()
    }

    func getCurrentFavoriteTeams() -> Set<String> {
        currentFavorites
    }

    func sendObservedFavorites(_ ids: Set<String>) {
        observeSubject.send(ids)
    }
}
