// ToggleFavoriteTeamUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ToggleFavoriteTeamUseCaseTests: XCTestCase {

    private var service: MockFavoritesService!
    private var sut: ToggleFavoriteTeamUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = MockFavoritesService()
        sut = ToggleFavoriteTeamUseCase(service: service)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        service = nil
        super.tearDown()
    }

    func test_execute_callsServiceToggle() throws {
        service.toggleResult = .success(true)
        _ = try awaitValue(from: sut.execute(teamId: "alianza"))
        XCTAssertEqual(service.toggleCallCount, 1)
    }

    func test_execute_passesTeamIdToService() throws {
        service.toggleResult = .success(true)
        _ = try awaitValue(from: sut.execute(teamId: "cristal"))
        XCTAssertEqual(service.lastToggledTeamId, "cristal")
    }

    func test_execute_returnsTrue_whenTeamAdded() throws {
        service.toggleResult = .success(true)
        let result = try awaitValue(from: sut.execute(teamId: "alianza"))
        XCTAssertTrue(result)
    }

    func test_execute_returnsFalse_whenTeamRemoved() throws {
        service.toggleResult = .success(false)
        let result = try awaitValue(from: sut.execute(teamId: "alianza"))
        XCTAssertFalse(result)
    }

    func test_execute_propagatesError() {
        service.toggleResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error")
        sut.execute(teamId: "alianza")
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }
}
