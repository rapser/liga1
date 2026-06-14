// ProfileViewModelTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class ProfileViewModelTests: XCTestCase {

    private var authService: MockAuthService!
    private var logoutUseCase: MockLogoutUseCase!
    private var sut: ProfileViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        logoutUseCase = MockLogoutUseCase()
        sut = ProfileViewModel(authService: authService, logoutUseCase: logoutUseCase)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        logoutUseCase = nil
        authService = nil
        super.tearDown()
    }

    // MARK: - Sections setup

    func test_init_setupsSections() {
        XCTAssertFalse(sut.sections.isEmpty)
    }

    // MARK: - Auth state observation

    func test_init_observesAuthState() {
        XCTAssertEqual(authService.observeAuthStateCallCount, 1)
    }

    func test_authStateChange_updatesDisplayName() {
        let user = User.fixture(displayName: "Miguel")
        let exp = expectation(description: "displayName updated")

        sut.$displayName
            .dropFirst()
            .sink { name in
                if name == "Miguel" { exp.fulfill() }
            }
            .store(in: &cancellables)

        authService.sendAuthState(user)
        waitForExpectations(timeout: 2)
        XCTAssertEqual(sut.displayName, "Miguel")
    }

    func test_authStateChange_updatesEmail() {
        let user = User.fixture(email: "miguel@liga1.pe")
        let exp = expectation(description: "email updated")

        sut.$email
            .dropFirst()
            .sink { email in
                if email == "miguel@liga1.pe" { exp.fulfill() }
            }
            .store(in: &cancellables)

        authService.sendAuthState(user)
        waitForExpectations(timeout: 2)
        XCTAssertEqual(sut.email, "miguel@liga1.pe")
    }

    // MARK: - Logout - success

    func test_logout_callsLogoutUseCase() {
        sut.logout()
        XCTAssertEqual(logoutUseCase.executeCallCount, 1)
    }

    func test_logout_success_setsLogoutSuccessful() {
        logoutUseCase.result = .success(())

        let exp = expectation(description: "logoutSuccessful becomes true")
        sut.$logoutSuccessful
            .dropFirst()
            .sink { if $0 { exp.fulfill() } }
            .store(in: &cancellables)

        sut.logout()
        waitForExpectations(timeout: 2)
        XCTAssertTrue(sut.logoutSuccessful)
    }

    func test_logout_success_clearsError() {
        logoutUseCase.result = .success(())
        sut.logout()

        let exp = expectation(description: "isLoading resets")
        sut.$isLoading
            .filter { !$0 }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertNil(sut.error)
    }

    // MARK: - Logout - failure

    func test_logout_failure_doesNotSetLogoutSuccessful() {
        logoutUseCase.result = .failure(TestError.network)
        sut.logout()

        let exp = expectation(description: "isLoading resets after failure")
        sut.$isLoading
            .filter { !$0 }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertFalse(sut.logoutSuccessful)
    }

    func test_logout_failure_setsError() {
        logoutUseCase.result = .failure(TestError.network)

        let exp = expectation(description: "error set")
        sut.$error
            .compactMap { $0 }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        sut.logout()
        waitForExpectations(timeout: 2)
        XCTAssertNotNil(sut.error)
    }

    // MARK: - isLoading

    func test_logout_setsIsLoadingTrue_thenFalse() {
        var loadingStates: [Bool] = []
        let exp = expectation(description: "loading transitions captured")

        sut.$isLoading
            .dropFirst()  // skip initial false
            .sink { state in
                loadingStates.append(state)
                if loadingStates.count == 2 { exp.fulfill() }
            }
            .store(in: &cancellables)

        sut.logout()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(loadingStates, [true, false])
    }
}
