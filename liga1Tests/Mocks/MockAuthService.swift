// MockAuthService.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockAuthService: AuthServiceProtocol {

    // MARK: - Stubbable results

    var loginResult: Result<User, Error> = .success(.fixture())
    var signInWithGoogleResult: Result<User, Error> = .success(.fixture())
    var logoutResult: Result<Void, Error> = .success(())

    // MARK: - Call tracking

    var loginCallCount = 0
    var signInWithGoogleCallCount = 0
    var logoutCallCount = 0
    var observeAuthStateCallCount = 0
    var lastLoginEmail: String?
    var lastLoginPassword: String?

    // MARK: - Observable auth state

    private let authStateSubject = CurrentValueSubject<User?, Never>(nil)

    var currentUserId: String? { authStateSubject.value?.id }

    // MARK: - AuthServiceProtocol

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        return loginResult.publisher.eraseToAnyPublisher()
    }

    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        signInWithGoogleCallCount += 1
        return signInWithGoogleResult.publisher.eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, Error> {
        logoutCallCount += 1
        return logoutResult.publisher.eraseToAnyPublisher()
    }

    func observeAuthState() -> AnyPublisher<User?, Never> {
        observeAuthStateCallCount += 1
        return authStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Test helpers

    func sendAuthState(_ user: User?) {
        authStateSubject.send(user)
    }
}
