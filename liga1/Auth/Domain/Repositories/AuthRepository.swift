//
//  AuthRepository.swift
//  liga1
//
//  Auth/Domain/Repositories: Protocol para repositorio de autenticación.
//  Created on 31/01/26.
//

import Foundation
import Combine

/// Protocol para repositorio de autenticación (sin dependencias de Firebase)
public protocol AuthRepository {
    /// Autenticarse con email y contraseña
    func login(email: String, password: String) -> AnyPublisher<User, Error>

    /// Autenticarse con credenciales de Google
    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error>

    /// Cerrar sesión
    func logout() -> AnyPublisher<Void, Error>

    /// Obtener usuario actual (si existe)
    func getCurrentUser() -> AnyPublisher<User?, Never>

    /// Observar cambios en el estado de autenticación
    func observeAuthState() -> AnyPublisher<User?, Never>
}
