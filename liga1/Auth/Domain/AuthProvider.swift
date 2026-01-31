//
//  AuthProvider.swift
//  liga1
//
//  Auth/Domain: protocolo que abstrae el acceso al usuario autenticado.
//

import Foundation

/// Protocolo que abstrae el acceso al usuario autenticado.
/// Permite inyectar dependencias y facilita testing.
public protocol AuthProvider {
    var currentUserId: String? { get }
}
