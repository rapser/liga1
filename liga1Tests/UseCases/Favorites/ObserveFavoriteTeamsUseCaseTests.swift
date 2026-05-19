// ObserveFavoriteTeamsUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ObserveFavoriteTeamsUseCaseTests: XCTestCase {

    private var service: MockFavoritesService!
    private var sut: ObserveFavoriteTeamsUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = MockFavoritesService()
        sut = ObserveFavoriteTeamsUseCase(service: service)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        service = nil
        super.tearDown()
    }

    // MARK: - execute()

    func test_execute_callsServiceObserve() {
        _ = sut.execute()
        XCTAssertEqual(service.observeCallCount, 1)
    }

    func test_execute_forwardsEmptyInitialValue() {
        let received = awaitFirstValue(from: sut.execute())
        XCTAssertEqual(received, [])
    }

    func test_execute_forwardsFavoriteIdsPushedByService() {
        let expected: Set<String> = ["alianza", "universitario"]
        var received: Set<String> = []
        let exp = expectation(description: "update received")
        exp.expectedFulfillmentCount = 2

        sut.execute()
            .sink { received = $0; exp.fulfill() }
            .store(in: &cancellables)

        service.sendObservedFavorites(expected)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received, expected)
    }

    func test_execute_forwardsMultipleUpdates() {
        let first: Set<String> = ["alianza"]
        let second: Set<String> = ["alianza", "cristal"]
        var received: [Set<String>] = []
        let exp = expectation(description: "three values")
        exp.expectedFulfillmentCount = 3

        sut.execute()
            .sink { received.append($0); exp.fulfill() }
            .store(in: &cancellables)

        service.sendObservedFavorites(first)
        service.sendObservedFavorites(second)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received[1], first)
        XCTAssertEqual(received[2], second)
    }

    // MARK: - refreshFavoriteTeams()

    func test_refreshFavoriteTeams_callsServiceFetch() throws {
        service.fetchResult = .success(())
        try awaitCompletion(of: sut.refreshFavoriteTeams())
        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func test_refreshFavoriteTeams_propagatesError() {
        service.fetchResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error")
        sut.refreshFavoriteTeams()
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }
}
