// FetchNewsUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class FetchNewsUseCaseTests: XCTestCase {

    private var repository: MockNewsRepository!
    private var sut: FetchNewsUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockNewsRepository()
        sut = FetchNewsUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_callsRepository() throws {
        _ = try awaitValue(from: sut.execute())
        XCTAssertEqual(repository.fetchCallCount, 1)
    }

    func test_execute_returnsNewsItems() throws {
        let expected = [
            NewsItem.fixture(title: "Titular 1"),
            NewsItem.fixture(title: "Titular 2")
        ]
        repository.fetchResult = .success(expected)

        let result = try awaitValue(from: sut.execute())

        XCTAssertEqual(result, expected)
    }

    func test_execute_returnsEmptyArray_whenRepositoryReturnsEmpty() throws {
        repository.fetchResult = .success([])
        let result = try awaitValue(from: sut.execute())
        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_propagatesRepositoryError() {
        repository.fetchResult = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error")
        sut.execute()
            .sink(
                receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }
}
