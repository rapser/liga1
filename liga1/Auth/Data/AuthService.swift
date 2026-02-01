//
//  AuthService.swift
//  liga1
//
//  Auth/Data: implementación de autenticación (Firebase Auth).
//  Refactored on 31/01/26 to implement AuthRepository.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import Combine

/// Implementación de AuthRepository usando Firebase Auth
public final class AuthService: AuthRepository, AuthProvider {

    // MARK: - Auth state observation

    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger: LoggerProtocol

    // MARK: - AuthProvider

    public var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Initialization

    public init(logger: LoggerProtocol) {
        self.logger = logger

        // Inicializar con el usuario actual si existe
        if let firebaseUser = Auth.auth().currentUser {
            currentUserSubject.send(UserMapper.toDomain(from: firebaseUser))
        }

        // Observar cambios en el estado de autenticación
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            let domainUser = UserMapper.toDomainOptional(from: firebaseUser)
            self?.currentUserSubject.send(domainUser)
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - AuthRepository

    public func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let firebaseUser = result?.user else {
                    let error = NSError(
                        domain: "AuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario"]
                    )
                    promise(.failure(error))
                    return
                }

                let user = UserMapper.toDomain(from: firebaseUser)
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }

    public func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            let firebaseCredential = GoogleAuthProvider.credential(
                withIDToken: credential.idToken,
                accessToken: credential.accessToken
            )

            Auth.auth().signIn(with: firebaseCredential) { result, error in
                if let error = error {
                    self.logger.error("❌ AuthService: Error al autenticar con Firebase", error: error)
                    promise(.failure(error))
                    return
                }

                guard let firebaseUser = result?.user else {
                    let error = NSError(
                        domain: "AuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario"]
                    )
                    promise(.failure(error))
                    return
                }

                let user = UserMapper.toDomain(from: firebaseUser)
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }

    public func logout() -> AnyPublisher<Void, Error> {
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

    public func getCurrentUser() -> AnyPublisher<User?, Never> {
        let firebaseUser = Auth.auth().currentUser
        let domainUser = UserMapper.toDomainOptional(from: firebaseUser)
        return Just(domainUser)
            .eraseToAnyPublisher()
    }

    public func observeAuthState() -> AnyPublisher<User?, Never> {
        return currentUserSubject
            .eraseToAnyPublisher()
    }

    // MARK: - Additional Methods (para compatibilidad interna)

    /// Observa al usuario actual (alias de observeAuthState para compatibilidad)
    public func observeCurrentUser() -> AnyPublisher<User?, Never> {
        return observeAuthState()
    }
}
