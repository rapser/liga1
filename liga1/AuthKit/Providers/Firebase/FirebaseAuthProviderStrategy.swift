//
//  FirebaseAuthProviderStrategy.swift
//  liga1
//
//  AuthKit/Providers/Firebase: Implementación de AuthProviderStrategy usando Firebase Auth.
//  Migrado desde AuthService.swift - Created on 15/02/26.
//

import Foundation
import FirebaseAuth
import Combine

/// Implementación de AuthProviderStrategy usando Firebase Authentication
/// Adapter Pattern: Adapta Firebase Auth SDK a la interfaz common de AuthKit
final class FirebaseAuthProviderStrategy: AuthProviderStrategy {

    // MARK: - Properties

    private let logger: LoggerProtocol
    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    // MARK: - AuthProviderStrategy

    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Initialization

    init(logger: LoggerProtocol) {
        self.logger = logger

        // Inicializar con el usuario actual si existe
        if let firebaseUser = Auth.auth().currentUser {
            currentUserSubject.send(FirebaseUserMapper.toDomain(from: firebaseUser))
        }

        // Observar cambios en el estado de autenticación
        setupAuthStateListener()
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Observation

    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            let domainUser = FirebaseUserMapper.toDomainOptional(from: firebaseUser)
            self?.currentUserSubject.send(domainUser)
        }
    }

    // MARK: - AuthProviderStrategy Implementation

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let firebaseUser = result?.user else {
                    let error = NSError(
                        domain: "FirebaseAuthProviderStrategy",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario"]
                    )
                    promise(.failure(error))
                    return
                }

                let user = FirebaseUserMapper.toDomain(from: firebaseUser)
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }

    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            let firebaseCredential = GoogleAuthProvider.credential(
                withIDToken: credential.idToken,
                accessToken: credential.accessToken
            )

            Auth.auth().signIn(with: firebaseCredential) { result, error in
                if let error = error {
                    self?.logger.error("FirebaseAuthProviderStrategy: Error al autenticar con Google", error: error)
                    promise(.failure(error))
                    return
                }

                guard let firebaseUser = result?.user else {
                    let error = NSError(
                        domain: "FirebaseAuthProviderStrategy",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario"]
                    )
                    promise(.failure(error))
                    return
                }

                let user = FirebaseUserMapper.toDomain(from: firebaseUser)
                promise(.success(user))
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

    func observeAuthState() -> AnyPublisher<User?, Never> {
        return currentUserSubject.eraseToAnyPublisher()
    }
}
