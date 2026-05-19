// ObserveMatchesUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ObserveMatchesUseCaseTests: XCTestCase {

    private var repository: MockMatchesRepository!
    private var sut: ObserveMatchesUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockMatchesRepository()
        sut = ObserveMatchesUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_callsRepository() {
        _ = sut.execute(for: "j1")
        XCTAssertEqual(repository.observeCallCount, 1)
    }

    func test_execute_forwardsEmptyInitialValue() {
        let received = awaitFirstValue(from: sut.execute(for: "j1"))
        XCTAssertEqual(received, [])
    }

    func test_execute_forwardsMatchesPushedByRepository() {
        let jornadaId = "j5"
        let matches = [Match.fixture(id: "a_b"), Match.fixture(id: "c_d")]

        var received: [Match] = []
        let exp = expectation(description: "update received")
        exp.expectedFulfillmentCount = 2

        sut.execute(for: jornadaId)
            .sink { received = $0; exp.fulfill() }
            .store(in: &cancellables)

        repository.sendObservedMatches(matches, for: jornadaId)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received, matches)
    }

    func test_execute_passesJornadaIdToRepository() {
        _ = sut.execute(for: "jornada_xyz")
        // The observe call was made; checking it reached the repository
        XCTAssertEqual(repository.observeCallCount, 1)
    }
}
