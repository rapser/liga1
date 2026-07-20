// MockNotificationTopicManager.swift
// liga1Tests

import Foundation
@testable import liga1

final class MockNotificationTopicManager: NotificationTopicManagerProtocol {

    var startObservingCallCount = 0
    var stopObservingCallCount = 0
    var syncCallCount = 0
    var unsubscribeAllCallCount = 0
    var resubscribeCallCount = 0

    func startObserving() {
        startObservingCallCount += 1
    }

    func stopObserving() {
        stopObservingCallCount += 1
    }

    func syncTopicsWithFavorites() {
        syncCallCount += 1
    }

    func unsubscribeFromAllTeamTopics() {
        unsubscribeAllCallCount += 1
    }

    func resubscribeToSavedTopics() {
        resubscribeCallCount += 1
    }
}
