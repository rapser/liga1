// ObserveActiveJornadasUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ObserveActiveJornadasUseCaseTests: XCTestCase {

    private var repository: MockJornadasRepository!
    private var sut: ObserveActiveJornadasUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockJornadasRepository()
        sut = ObserveActiveJornadasUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_callsRepository() {
        _ = sut.execute()
        XCTAssertEqual(repository.observeCallCount, 1)
    }

    func test_execute_forwardsEmptyInitialValue() {
        let received = awaitFirstValue(from: sut.execute())
        XCTAssertEqual(received, [])
    }

    func test_execute_forwardsJornadasPushedByRepository() {
        let jornadas = [Jornada.fixture(id: "j10"), Jornada.fixture(id: "j11")]
        var results: [[Jornada]] = []
        let expectation = expectation(description: "two values received")
        expectation.expectedFulfillmentCount = 2

        sut.execute()
            .sink { received in
                results.append(received)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        repository.sendObservedJornadas(jornadas)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(results.last, jornadas)
    }

    func test_execute_forwardsMultipleUpdates() {
        let first = [Jornada.fixture(id: "a")]
        let second = [Jornada.fixture(id: "a"), Jornada.fixture(id: "b")]
        var results: [[Jornada]] = []
        let expectation = expectation(description: "three values")
        expectation.expectedFulfillmentCount = 3

        sut.execute()
            .sink { results.append($0); expectation.fulfill() }
            .store(in: &cancellables)

        repository.sendObservedJornadas(first)
        repository.sendObservedJornadas(second)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(results[1], first)
        XCTAssertEqual(results[2], second)
    }
}
