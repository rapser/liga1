//
//  AuthServiceProtocol.swift
//  liga1
//
//  AuthKit/Core: Protocolo público del servicio de autenticación.
//  Permite inyectar AuthManager como dependencia en lugar de acceder al singleton directamente.
//

import Foundation
import Combine

/// Contrato público del servicio de autenticación.
/// AuthManager conforma este protocolo — los callers dependen de esta abstracción, no del concreto.
public protocol AuthServiceProtocol: AnyObject {

    /// ID del usuario actualmente autenticado (nil si no hay sesión)
    var currentUserId: String? { get }

    /// Inicia sesión con email y contraseña
    func login(email: String, password: String) -> AnyPublisher<User, Error>

    /// Inicia sesión con credenciales de Google
    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error>

    /// Cierra la sesión actual
    func logout() -> AnyPublisher<Void, Error>

    /// Observa cambios en el estado de autenticación
    func observeAuthState() -> AnyPublisher<User?, Never>
}
