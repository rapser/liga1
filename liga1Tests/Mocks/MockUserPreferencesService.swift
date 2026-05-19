// MockUserPreferencesService.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockUserPreferencesService: UserPreferencesServiceProtocol {

    // MARK: - updatePushNotificationsEnabled
    var updateResult: Result<Void, Error> = .success(())
    var updateCallCount = 0
    var lastEnabledValue: Bool?

    // MARK: - observePreferences
    private let preferencesSubject = CurrentValueSubject<UserPreferences?, Never>(nil)
    var observeCallCount = 0

    // MARK: - getUserPreferences
    var getUserPreferencesResult: Result<UserPreferences?, Error> = .success(nil)

    // MARK: - topic stubs (unused in these tests)
    var addTopicResult: Result<Void, Error> = .success(())
    var removeTopicResult: Result<Void, Error> = .success(())
    var setTopicsResult: Result<Void, Error> = .success(())

    func updatePushNotificationsEnabled(_ enabled: Bool) -> AnyPublisher<Void, Error> {
        updateCallCount += 1
        lastEnabledValue = enabled
        switch updateResult {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func observePreferences() -> AnyPublisher<UserPreferences?, Never> {
        observeCallCount += 1
        return preferencesSubject.eraseToAnyPublisher()
    }

    func getUserPreferences() -> AnyPublisher<UserPreferences?, Error> {
        switch getUserPreferencesResult {
        case .success(let prefs):
            return Just(prefs).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func addSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error> {
        switch addTopicResult {
        case .success: return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let e): return Fail(error: e).eraseToAnyPublisher()
        }
    }

    func removeSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error> {
        switch removeTopicResult {
        case .success: return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let e): return Fail(error: e).eraseToAnyPublisher()
        }
    }

    func setSubscribedTopics(_ topics: Set<String>) -> AnyPublisher<Void, Error> {
        switch setTopicsResult {
        case .success: return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let e): return Fail(error: e).eraseToAnyPublisher()
        }
    }

    func sendObservedPreferences(_ prefs: UserPreferences?) {
        preferencesSubject.send(prefs)
    }
}
