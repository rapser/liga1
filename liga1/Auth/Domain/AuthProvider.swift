//
//  AuthProvider.swift
//  liga1
//
//  Auth/Domain: protocolo que abstrae el acceso al usuario autenticado.
//

import Foundation
import Combine

/// Protocolo que abstrae el acceso al usuario autenticado.
/// Permite inyectar dependencias y facilita testing.
public protocol AuthProvider {
    /// ID del usuario actualmente autenticado (nil si no hay sesión)
    var currentUserId: String? { get }

    /// Observa cambios en el usuario actual (login/logout)
    func observeCurrentUser() -> AnyPublisher<User?, Never>
}
