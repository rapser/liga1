//
//  AuthProviderType.swift
//  liga1
//
//  AuthKit/Core: Enum para configurar el tipo de proveedor de autenticación.
//  Created on 15/02/26.
//

import Foundation

/// Tipo de proveedor de autenticación
/// Permite configurar qué strategy usar en runtime
public enum AuthProviderType {
    /// Firebase Authentication
    case firebase

    /// Supabase Authentication (futuro - v2.0)
    case supabase(url: String, anonKey: String)

    /// REST API con autenticación custom (futuro - v2.0)
    case rest(baseURL: URL, sslPinning: SSLPinningConfig?)
}

/// Configuración para SSL Certificate Pinning (futuro - v2.0)
public struct SSLPinningConfig {
    /// Certificados públicos para validar
    public let certificates: [Data]

    /// Si debe validar el hostname
    public let validateHost: Bool

    public init(certificates: [Data], validateHost: Bool) {
        self.certificates = certificates
        self.validateHost = validateHost
    }
}
