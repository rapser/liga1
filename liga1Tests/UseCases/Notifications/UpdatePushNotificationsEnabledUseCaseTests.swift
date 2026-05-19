// UpdatePushNotificationsEnabledUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class UpdatePushNotificationsEnabledUseCaseTests: XCTestCase {

    private var preferencesService: MockUserPreferencesService!
    private var topicManager: MockNotificationTopicManager!
    private var logger: MockLogger!
    private var sut: UpdatePushNotificationsEnabledUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        preferencesService = MockUserPreferencesService()
        topicManager = MockNotificationTopicManager()
        logger = MockLogger()
        sut = UpdatePushNotificationsEnabledUseCase(
            userPreferencesService: preferencesService,
            notificationTopicManager: topicManager,
            logger: logger
        )
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        preferencesService = nil
        topicManager = nil
        logger = nil
        super.tearDown()
    }

    // MARK: - Service delegation

    func test_execute_callsServiceWithCorrectValue() throws {
        preferencesService.updateResult = .success(())
        try awaitCompletion(of: sut.execute(enabled: true))
        XCTAssertEqual(preferencesService.updateCallCount, 1)
        XCTAssertEqual(preferencesService.lastEnabledValue, true)
    }

    func test_execute_disabled_passesCorrectValueToService() throws {
        preferencesService.updateResult = .success(())
        try awaitCompletion(of: sut.execute(enabled: false))
        XCTAssertEqual(preferencesService.lastEnabledValue, false)
    }

    // MARK: - Topic management on success

    func test_execute_enabled_callsResubscribeToSavedTopics() throws {
        preferencesService.updateResult = .success(())
        try awaitCompletion(of: sut.execute(enabled: true))
        XCTAssertEqual(topicManager.resubscribeCallCount, 1)
        XCTAssertEqual(topicManager.unsubscribeAllCallCount, 0)
    }

    func test_execute_disabled_callsUnsubscribeFromAllTeamTopics() throws {
        preferencesService.updateResult = .success(())
        try awaitCompletion(of: sut.execute(enabled: false))
        XCTAssertEqual(topicManager.unsubscribeAllCallCount, 1)
        XCTAssertEqual(topicManager.resubscribeCallCount, 0)
    }

    // MARK: - Error handling

    func test_execute_failure_propagatesError() {
        preferencesService.updateResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error propagated")
        sut.execute(enabled: true)
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }

    func test_execute_failure_logsError() {
        preferencesService.updateResult = .failure(TestError.generic)

        let exp = expectation(description: "logger called")
        var cancellable: AnyCancellable?
        cancellable = sut.execute(enabled: true)
            .sink(
                receiveCompletion: { _ in
                    DispatchQueue.main.async {
                        exp.fulfill()
                        _ = cancellable
                    }
                },
                receiveValue: { _ in }
            )

        waitForExpectations(timeout: 2)
        XCTAssertEqual(logger.errorCallCount, 1)
    }

    func test_execute_failure_doesNotCallTopicManager() {
        preferencesService.updateResult = .failure(TestError.network)

        let exp = expectation(description: "completed")
        sut.execute(enabled: true)
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(topicManager.resubscribeCallCount, 0)
        XCTAssertEqual(topicManager.unsubscribeAllCallCount, 0)
    }

    // MARK: - Success completes publisher

    func test_execute_success_completesPublisher() throws {
        preferencesService.updateResult = .success(())
        try awaitCompletion(of: sut.execute(enabled: true))
        // No assertion needed — awaitCompletion throws if publisher fails
    }
}
