//
//  AuthManager.swift
//  liga1
//
//  AuthKit/Core: Facade Pattern - API pública simplificada para autenticación.
//  Created on 15/02/26.
//

import Foundation
import Combine

/// Facade Pattern: API pública simplificada de AuthKit
/// Punto de entrada principal para todas las operaciones de autenticación
public final class AuthManager {

    // MARK: - Singleton

    public static let shared = AuthManager()

    // MARK: - Private Properties

    private var strategy: AuthProviderStrategy?
    private let logger: LoggerProtocol

    // MARK: - Initialization

    private init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }

    // MARK: - Configuration

    /// Configura el proveedor de autenticación
    /// IMPORTANTE: Debe llamarse antes de usar cualquier método de auth
    /// - Parameter provider: Tipo de proveedor (firebase, supabase, rest)
    public func configure(provider: AuthProviderType) {
        self.strategy = AuthProviderFactory.create(type: provider, logger: logger)
        logger.info("AuthManager configurado con proveedor: \(provider)")
    }

    // MARK: - Current User

    /// ID del usuario actualmente autenticado (nil si no hay sesión)
    public var currentUserId: String? {
        return strategy?.currentUserId
    }

    // MARK: - Authentication Methods

    /// Inicia sesión con email y contraseña
    /// - Parameters:
    ///   - email: Email del usuario
    ///   - password: Contraseña del usuario
    /// - Returns: Publisher con el usuario autenticado o error
    public func login(email: String, password: String) -> AnyPublisher<User, Error> {
        guard let strategy = strategy else {
            return Fail(error: AuthError.notConfigured).eraseToAnyPublisher()
        }
        return strategy.login(email: email, password: password)
    }

    /// Inicia sesión con credenciales de Google
    /// - Parameter credential: Credenciales de Google (idToken + accessToken)
    /// - Returns: Publisher con el usuario autenticado o error
    public func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        guard let strategy = strategy else {
            return Fail(error: AuthError.notConfigured).eraseToAnyPublisher()
        }
        return strategy.signInWithGoogle(credential: credential)
    }

    /// Cierra la sesión actual
    /// - Returns: Publisher que completa cuando el logout termina
    public func logout() -> AnyPublisher<Void, Error> {
        guard let strategy = strategy else {
            return Fail(error: AuthError.notConfigured).eraseToAnyPublisher()
        }
        return strategy.logout()
    }

    /// Observa cambios en el estado de autenticación
    /// - Returns: Publisher que emite el usuario actual cada vez que cambia
    public func observeAuthState() -> AnyPublisher<User?, Never> {
        guard let strategy = strategy else {
            return Just(nil).eraseToAnyPublisher()
        }
        return strategy.observeAuthState()
    }
}

// MARK: - AuthServiceProtocol Conformance

extension AuthManager: AuthServiceProtocol {}

// MARK: - Auth Errors

/// Errores específicos de AuthKit
public enum AuthError: LocalizedError {
    case notConfigured

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AuthKit no está configurado. Llama a AuthManager.shared.configure(provider:) primero."
        }
    }
}
