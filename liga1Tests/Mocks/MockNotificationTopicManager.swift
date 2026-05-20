// MockNotificationTopicManager.swift
// liga1Tests

import Foundation
@testable import liga1

final class MockNotificationTopicManager: NotificationTopicManagerProtocol {

    var syncCallCount = 0
    var unsubscribeAllCallCount = 0
    var resubscribeCallCount = 0

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
