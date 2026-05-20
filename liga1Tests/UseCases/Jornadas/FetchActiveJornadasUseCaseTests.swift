// FetchActiveJornadasUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class FetchActiveJornadasUseCaseTests: XCTestCase {

    private var repository: MockJornadasRepository!
    private var logger: MockLogger!
    private var sut: FetchActiveJornadasUseCase!

    override func setUp() {
        super.setUp()
        repository = MockJornadasRepository()
        logger = MockLogger()
        sut = FetchActiveJornadasUseCase(repository: repository, logger: logger)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        logger = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_execute_callsRepository() throws {
        repository.fetchResult = .success([])
        _ = try awaitValue(from: sut.execute())
        XCTAssertEqual(repository.fetchCallCount, 1)
    }

    func test_execute_success_returnsJornadas() throws {
        let expected = [
            Jornada.fixture(id: "j1"),
            Jornada.fixture(id: "j2")
        ]
        repository.fetchResult = .success(expected)

        let result = try awaitValue(from: sut.execute())

        XCTAssertEqual(result, expected)
    }

    func test_execute_success_doesNotLogError() throws {
        repository.fetchResult = .success([Jornada.fixture()])
        _ = try awaitValue(from: sut.execute())
        XCTAssertEqual(logger.errorCallCount, 0)
    }

    // MARK: - Failure

    func test_execute_failure_propagatesError() {
        repository.fetchResult = .failure(TestError.network)

        var receivedError: Error?
        let expectation = expectation(description: "error received")
        let cancellable = sut.execute().sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                    expectation.fulfill()
                }
            },
            receiveValue: { _ in }
        )
        waitForExpectations(timeout: 2)
        XCTAssertNotNil(receivedError)
        _ = cancellable
    }

    func test_execute_failure_logsError() {
        repository.fetchResult = .failure(TestError.generic)

        let expectation = expectation(description: "logger called")
        var cancellable: AnyCancellable?
        cancellable = sut.execute().sink(
            receiveCompletion: { [weak self] _ in
                // handleEvents logs on completion
                DispatchQueue.main.async {
                    expectation.fulfill()
                    _ = cancellable
                }
            },
            receiveValue: { _ in }
        )
        waitForExpectations(timeout: 2)
        XCTAssertEqual(logger.errorCallCount, 1)
    }
}
