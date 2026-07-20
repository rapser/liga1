// LogoutUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class LogoutUseCaseTests: XCTestCase {

    private var authService: MockAuthService!
    private var sut: LogoutUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        sut = LogoutUseCase(authService: authService)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        authService = nil
        super.tearDown()
    }

    // MARK: - Delegation

    func test_execute_callsAuthService() throws {
        try awaitCompletion(of: sut.execute())
        XCTAssertEqual(authService.logoutCallCount, 1)
    }

    func test_execute_calledTwice_callsAuthServiceTwice() throws {
        try awaitCompletion(of: sut.execute())
        try awaitCompletion(of: sut.execute())
        XCTAssertEqual(authService.logoutCallCount, 2)
    }

    // MARK: - Success

    func test_execute_success_completesWithoutError() throws {
        authService.logoutResult = .success(())
        XCTAssertNoThrow(try awaitCompletion(of: sut.execute()))
    }

    // MARK: - Failure

    func test_execute_failure_propagatesError() {
        authService.logoutResult = .failure(TestError.network)

        var capturedError: Error?
        let exp = expectation(description: "error received")

        sut.execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        capturedError = e
                        exp.fulfill()
                    }
                },
                receiveValue: { }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(capturedError is TestError)
    }
}
