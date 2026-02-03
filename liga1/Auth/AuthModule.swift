//
//  AuthModule.swift
//  liga1
//
//  Auth: Módulo de autenticación - Public Interface (Facade).
//  Created on 31/01/26.
//

import Foundation
import UIKit
import Combine

/// Módulo de autenticación - Interfaz pública (Facade)
/// Esta es la ÚNICA API que los consumidores deben usar
public final class AuthModule {

    // MARK: - Private

    private static var authService: AuthService?

    private static func getService() -> AuthService {
        if let service = authService {
            return service
        }
        let service = AuthService(logger: Logger.shared)
        authService = service
        return service
    }

    // MARK: - Configuration

    /// Configura el módulo de autenticación
    /// - Parameter logger: Logger para registro de eventos (opcional)
    public static func configure(logger: LoggerProtocol = Logger.shared) {
        authService = AuthService(logger: logger)
    }

    // MARK: - Current User

    /// Usuario actualmente autenticado (nil si no hay sesión)
    public static var currentUser: User? {
        getService().currentUserId != nil ? nil : nil // TODO: Implementar getCurrentUser sync
    }

    /// ID del usuario actualmente autenticado
    public static var currentUserId: String? {
        getService().currentUserId
    }

    /// Observa cambios en el estado de autenticación
    public static func observeAuthState() -> AnyPublisher<User?, Never> {
        getService().observeAuthState()
    }

    // MARK: - Authentication

    /// Inicia sesión con email y contraseña
    /// - Parameters:
    ///   - email: Correo electrónico
    ///   - password: Contraseña
    /// - Returns: Publisher con el usuario autenticado o error
    public static func login(email: String, password: String) -> AnyPublisher<User, Error> {
        getService().login(email: email, password: password)
    }

    /// Inicia sesión con Google
    /// - Parameter presentingViewController: ViewController para presentar la UI de Google
    /// - Returns: Publisher con el usuario autenticado o error
    public static func loginWithGoogle(presenting viewController: UIViewController) -> AnyPublisher<User, Error> {
        let provider = GoogleCredentialProviderImpl(presentingViewController: viewController)
        return provider.provideCredential()
            .flatMap { credential in
                getService().signInWithGoogle(credential: credential)
            }
            .eraseToAnyPublisher()
    }

    /// Cierra la sesión actual
    /// - Returns: Publisher que completa cuando el logout termina
    public static func logout() -> AnyPublisher<Void, Error> {
        getService().logout()
    }

    // MARK: - Coordinator (opcional - para apps que quieran UI incluida)

    /// Crea un coordinador de autenticación con UI incluida
    /// - Parameters:
    ///   - navigationController: Navigation controller para presentar las pantallas
    ///   - logger: Logger para registro de eventos
    /// - Returns: Coordinador configurado y listo para iniciar
    public static func makeCoordinator(
        navigationController: UINavigationController,
        logger: LoggerProtocol = Logger.shared
    ) -> AuthCoordinator {
        let diContainer = AuthDIContainer(logger: logger)
        return AuthCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
    }
}
