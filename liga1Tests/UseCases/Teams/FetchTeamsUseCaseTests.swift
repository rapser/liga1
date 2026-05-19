// FetchTeamsUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class FetchTeamsUseCaseTests: XCTestCase {

    private var repository: MockTeamsRepository!
    private var sut: FetchTeamsUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockTeamsRepository()
        sut = FetchTeamsUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - acumulado guard

    func test_execute_acumulado_failsImmediately() {
        var failed = false
        let exp = expectation(description: "fail for acumulado")

        sut.execute(for: .acumulado)
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }

    func test_execute_acumulado_doesNotCallRepository() {
        sut.execute(for: .acumulado)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    // MARK: - apertura

    func test_execute_apertura_callsRepository() throws {
        repository.fetchResult = .success([])
        _ = try awaitValue(from: sut.execute(for: .apertura))
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(repository.lastTorneoRequested, .apertura)
    }

    func test_execute_apertura_returnsTeams() throws {
        let expected = [Team.fixture(nombre: "Alianza"), Team.fixture(nombre: "Universitario")]
        repository.fetchResult = .success(expected)

        let result = try awaitValue(from: sut.execute(for: .apertura))

        XCTAssertEqual(result, expected)
    }

    // MARK: - clausura

    func test_execute_clausura_callsRepository() throws {
        repository.fetchResult = .success([])
        _ = try awaitValue(from: sut.execute(for: .clausura))
        XCTAssertEqual(repository.lastTorneoRequested, .clausura)
    }

    // MARK: - Error propagation

    func test_execute_apertura_propagatesRepositoryError() {
        repository.fetchResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error propagated")

        sut.execute(for: .apertura)
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }
}
