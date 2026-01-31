//
//  AuthService.swift
//  liga1
//
//  Auth/Data: implementación de autenticación (Firebase Auth).
//

import Foundation
import FirebaseAuth
import FirebaseCore
import Combine

protocol AuthServiceProtocol: AuthProvider {
    func login(email: String, password: String) -> AnyPublisher<Void, Error>
    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<Void, Error>
    func logout() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> AnyPublisher<User?, Never>
    /// Emite cada vez que cambia el estado de autenticación (login/logout).
    func observeCurrentUser() -> AnyPublisher<User?, Never>
}

class AuthService: AuthServiceProtocol, AuthProvider {

    // MARK: - Auth state observation

    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger: LoggerProtocol

    // MARK: - AuthProvider

    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    init(logger: LoggerProtocol) {
        self.logger = logger
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUserSubject.send(user)
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let firebaseCredential = GoogleAuthProvider.credential(
                withIDToken: credential.idToken,
                accessToken: credential.accessToken
            )
            Auth.auth().signIn(with: firebaseCredential) { _, error in
                if let error = error {
                    self.logger.error("❌ AuthService: Error al autenticar con Firebase", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func getCurrentUser() -> AnyPublisher<User?, Never> {
        return Just(Auth.auth().currentUser)
            .eraseToAnyPublisher()
    }

    func observeCurrentUser() -> AnyPublisher<User?, Never> {
        return currentUserSubject
            .eraseToAnyPublisher()
    }
}
