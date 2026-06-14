// LoginWithEmailUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class LoginWithEmailUseCaseTests: XCTestCase {

    private var authService: MockAuthService!
    private var sut: LoginWithEmailUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        sut = LoginWithEmailUseCase(authService: authService)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        authService = nil
        super.tearDown()
    }

    // MARK: - Validation (auth never called)

    func test_execute_emptyEmail_failsWithValidationError() {
        let error = try? awaitFailure(from: sut.execute(email: "", password: "Pass123!"))
        XCTAssertNotNil(error)
        XCTAssertEqual(authService.loginCallCount, 0, "Auth nunca debería llamarse con email inválido")
    }

    func test_execute_emptyPassword_failsWithValidationError() {
        let error = try? awaitFailure(from: sut.execute(email: "user@liga1.pe", password: ""))
        XCTAssertNotNil(error)
        XCTAssertEqual(authService.loginCallCount, 0)
    }

    func test_execute_invalidEmailFormat_failsWithValidationError() {
        let error = try? awaitFailure(from: sut.execute(email: "not-an-email", password: "Pass123!"))
        XCTAssertNotNil(error)
        XCTAssertEqual(authService.loginCallCount, 0)
    }

    // MARK: - Delegation to auth service

    func test_execute_validCredentials_callsAuthService() throws {
        authService.loginResult = .success(.fixture())
        _ = try awaitValue(from: sut.execute(email: "user@liga1.pe", password: "Pass123!"))
        XCTAssertEqual(authService.loginCallCount, 1)
    }

    func test_execute_validCredentials_forwardsEmailToAuthService() throws {
        authService.loginResult = .success(.fixture())
        _ = try awaitValue(from: sut.execute(email: "user@liga1.pe", password: "Pass123!"))
        XCTAssertEqual(authService.lastLoginEmail, "user@liga1.pe")
    }

    // MARK: - Success

    func test_execute_success_returnsUser() throws {
        let expected = User.fixture(email: "user@liga1.pe")
        authService.loginResult = .success(expected)

        let result = try awaitValue(from: sut.execute(email: "user@liga1.pe", password: "Pass123!"))
        XCTAssertEqual(result, expected)
    }

    // MARK: - Auth failure

    func test_execute_authFailure_propagatesError() {
        authService.loginResult = .failure(TestError.network)

        let error = try? awaitFailure(from: sut.execute(email: "user@liga1.pe", password: "Pass123!"))
        XCTAssertNotNil(error)
    }
}
