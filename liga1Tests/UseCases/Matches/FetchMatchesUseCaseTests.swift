// FetchMatchesUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class FetchMatchesUseCaseTests: XCTestCase {

    private var repository: MockMatchesRepository!
    private var sut: FetchMatchesUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockMatchesRepository()
        sut = FetchMatchesUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Empty jornadaId guard

    func test_execute_emptyJornadaId_returnsError() {
        var failed = false
        let exp = expectation(description: "error for empty id")

        sut.execute(for: "", calendarDay: Date())
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
        XCTAssertEqual(repository.fetchCallCount, 0, "Repository must not be called when jornadaId is empty")
    }

    // MARK: - Day filtering (Lima timezone)

    func test_execute_returnsOnlyMatchesOnRequestedDay() throws {
        let targetDay = limaDate(year: 2025, month: 4, day: 5)
        let matchOnDay    = Match.fixture(id: "a_b", fecha: limaDate(year: 2025, month: 4, day: 5, hour: 15))
        let matchNextDay  = Match.fixture(id: "c_d", fecha: limaDate(year: 2025, month: 4, day: 6, hour: 10))
        let matchPrevDay  = Match.fixture(id: "e_f", fecha: limaDate(year: 2025, month: 4, day: 4, hour: 20))

        repository.fetchResult = .success([matchNextDay, matchOnDay, matchPrevDay])

        let result = try awaitValue(from: sut.execute(for: "j1", calendarDay: targetDay))

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "a_b")
    }

    func test_execute_limaTimezone_doesNotLeakIntoNextDay() throws {
        // 23:30 Lima = 04:30 UTC next day — still Lima's same day
        let targetDay = limaDate(year: 2025, month: 6, day: 10)
        let lateNightLima = Match.fixture(id: "x_y", fecha: limaDate(year: 2025, month: 6, day: 10, hour: 23, minute: 30))

        repository.fetchResult = .success([lateNightLima])

        let result = try awaitValue(from: sut.execute(for: "j1", calendarDay: targetDay))

        XCTAssertEqual(result.count, 1)
    }

    func test_execute_returnsEmpty_whenNothingMatchesDay() throws {
        let targetDay = limaDate(year: 2025, month: 1, day: 1)
        let matchOtherDay = Match.fixture(fecha: limaDate(year: 2025, month: 1, day: 2))
        repository.fetchResult = .success([matchOtherDay])

        let result = try awaitValue(from: sut.execute(for: "j1", calendarDay: targetDay))

        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_returnsEmpty_whenRepositoryReturnsEmpty() throws {
        repository.fetchResult = .success([])
        let result = try awaitValue(from: sut.execute(for: "j1", calendarDay: Date()))
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Sorting

    func test_execute_sortsByFechaAscending() throws {
        let day = limaDate(year: 2025, month: 5, day: 10)
        let early = Match.fixture(id: "e_f", fecha: limaDate(year: 2025, month: 5, day: 10, hour: 12))
        let late  = Match.fixture(id: "a_b", fecha: limaDate(year: 2025, month: 5, day: 10, hour: 20))
        let mid   = Match.fixture(id: "c_d", fecha: limaDate(year: 2025, month: 5, day: 10, hour: 16))

        repository.fetchResult = .success([late, early, mid])

        let result = try awaitValue(from: sut.execute(for: "j1", calendarDay: day))

        XCTAssertEqual(result.map(\.id), ["e_f", "c_d", "a_b"])
    }

    // MARK: - Repository delegation

    func test_execute_passesJornadaIdToRepository() throws {
        repository.fetchResult = .success([])
        _ = try awaitValue(from: sut.execute(for: "jornada_abc", calendarDay: Date()))
        XCTAssertEqual(repository.lastFetchedJornadaId, "jornada_abc")
    }

    // MARK: - Error propagation

    func test_execute_propagatesRepositoryError() {
        repository.fetchResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error propagated")

        sut.execute(for: "j1", calendarDay: Date())
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }
}
