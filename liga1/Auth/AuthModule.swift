//
//  AuthModule.swift
//  liga1
//
//  Auth: Módulo de autenticación - Public Interface (Facade).
//  Created on 31/01/26.
//

import Foundation
import UIKit

/// Módulo de autenticación - Interfaz pública
/// Proporciona acceso a funcionalidades del módulo sin exponer detalles internos
public final class AuthModule {

    // MARK: - Coordinator

    /// Crea un coordinador de autenticación
    /// - Parameters:
    ///   - navigationController: Navigation controller para presentar las pantallas
    ///   - logger: Logger para registro de eventos
    /// - Returns: Coordinador configurado y listo para iniciar
    public static func makeCoordinator(
        navigationController: UINavigationController,
        logger: LoggerProtocol
    ) -> AuthCoordinator {
        let diContainer = AuthDIContainer(logger: logger)
        return AuthCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
    }

    // MARK: - Repositories

    /// Crea una instancia del repositorio de autenticación
    /// Útil cuando otros módulos necesitan acceso a funcionalidades de auth
    /// - Parameter logger: Logger para registro de eventos
    /// - Returns: Repositorio de autenticación configurado
    public static func makeAuthRepository(logger: LoggerProtocol) -> AuthRepository {
        return AuthService(logger: logger)
    }

    // MARK: - Use Cases

    /// Crea el use case de login
    /// - Parameter logger: Logger para registro de eventos
    /// - Returns: Use case de login configurado
    public static func makeLoginUseCase(logger: LoggerProtocol) -> LoginUseCaseProtocol {
        let repository = makeAuthRepository(logger: logger)
        return LoginUseCase(authRepository: repository)
    }

    /// Crea el use case de logout
    /// - Parameter logger: Logger para registro de eventos
    /// - Returns: Use case de logout configurado
    public static func makeLogoutUseCase(logger: LoggerProtocol) -> LogoutUseCaseProtocol {
        let repository = makeAuthRepository(logger: logger)
        return LogoutUseCase(authRepository: repository)
    }

    // MARK: - Auth Provider

    /// Crea un provider de autenticación
    /// Útil cuando otros módulos solo necesitan verificar userId actual
    /// - Parameter logger: Logger para registro de eventos
    /// - Returns: Provider de autenticación
    public static func makeAuthProvider(logger: LoggerProtocol) -> AuthProvider {
        return AuthService(logger: logger)
    }
}
