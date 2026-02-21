//
//  AuthProviderFactory.swift
//  liga1
//
//  AuthKit/Core: Factory Pattern - crea el proveedor de auth correcto según configuración.
//  Created on 15/02/26.
//

import Foundation

/// Factory Pattern: Crea el proveedor de autenticación correcto según configuración
public struct AuthProviderFactory {

    /// Crea un proveedor de autenticación según el tipo configurado
    /// - Parameters:
    ///   - type: Tipo de proveedor (firebase, supabase, rest)
    ///   - logger: Logger para registro de eventos
    /// - Returns: Proveedor de autenticación configurado
    public static func create(
        type: AuthProviderType,
        logger: LoggerProtocol
    ) -> AuthProviderStrategy {
        switch type {
        case .firebase:
            return FirebaseAuthProviderStrategy(logger: logger)

        case .supabase(let url, let anonKey):
            return SupabaseAuthProviderStrategy(
                url: url,
                anonKey: anonKey,
                logger: logger
            )

        case .rest(let baseURL, let sslConfig):
            return RESTAuthProviderStrategy(
                baseURL: baseURL,
                sslPinning: sslConfig,
                logger: logger
            )
        }
    }
}
