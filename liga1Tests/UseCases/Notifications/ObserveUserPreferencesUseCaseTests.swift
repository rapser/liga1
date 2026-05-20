// ObserveUserPreferencesUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ObserveUserPreferencesUseCaseTests: XCTestCase {

    private var service: MockUserPreferencesService!
    private var sut: ObserveUserPreferencesUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = MockUserPreferencesService()
        sut = ObserveUserPreferencesUseCase(userPreferencesService: service)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        service = nil
        super.tearDown()
    }

    func test_execute_callsServiceObserve() {
        _ = sut.execute()
        XCTAssertEqual(service.observeCallCount, 1)
    }

    func test_execute_forwardsNilInitialValue() {
        let received = awaitFirstValue(from: sut.execute())
        XCTAssertNil(received as? UserPreferences)
    }

    func test_execute_forwardsPreferencesPushedByService() {
        let prefs = UserPreferences.fixture(pushEnabled: true, topics: ["alianza"])
        var received: UserPreferences?
        let exp = expectation(description: "update received")
        exp.expectedFulfillmentCount = 2

        sut.execute()
            .sink { received = $0; exp.fulfill() }
            .store(in: &cancellables)

        service.sendObservedPreferences(prefs)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received?.pushNotificationsEnabled, true)
        XCTAssertEqual(received?.subscribedTopics, ["alianza"])
    }

    func test_execute_forwardsNilPreferences() {
        let exp = expectation(description: "nil forwarded")
        exp.expectedFulfillmentCount = 2
        var values: [UserPreferences?] = []

        sut.execute()
            .sink { values.append($0); exp.fulfill() }
            .store(in: &cancellables)

        service.sendObservedPreferences(nil)

        waitForExpectations(timeout: 2)
        XCTAssertNil(values.last as? UserPreferences)
    }
}
