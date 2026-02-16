//
//  AuthProviderStrategy.swift
//  liga1
//
//  AuthKit/Core: Protocol base para Strategy Pattern - permite intercambiar proveedores de auth.
//  Created on 15/02/26.
//

import Foundation
import Combine

/// Strategy Pattern: Abstracción de un proveedor de autenticación
/// Permite intercambiar entre Firebase, Supabase, REST API sin cambiar código del cliente
public protocol AuthProviderStrategy {

    /// ID del usuario actualmente autenticado (nil si no hay sesión)
    var currentUserId: String? { get }

    /// Autentica con email y password
    /// - Parameters:
    ///   - email: Email del usuario
    ///   - password: Password del usuario
    /// - Returns: Publisher con el usuario autenticado o error
    func login(email: String, password: String) -> AnyPublisher<User, Error>

    /// Autentica con credenciales de Google
    /// - Parameter credential: Credenciales de Google (idToken + accessToken)
    /// - Returns: Publisher con el usuario autenticado o error
    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error>

    /// Cierra la sesión actual
    /// - Returns: Publisher que completa cuando el logout termina
    func logout() -> AnyPublisher<Void, Error>

    /// Observa cambios en el estado de autenticación
    /// - Returns: Publisher que emite el usuario actual cada vez que cambia (nil si no hay sesión)
    func observeAuthState() -> AnyPublisher<User?, Never>
}
