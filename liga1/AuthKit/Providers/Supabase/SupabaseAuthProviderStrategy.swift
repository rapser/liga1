//
//  SupabaseAuthProviderStrategy.swift
//  liga1
//
//  AuthKit/Providers/Supabase: Implementación de AuthProviderStrategy para Supabase.
//  STUB - Preparado para v2.0 - Created on 15/02/26.
//

import Foundation
import Combine

/// Implementación de AuthProviderStrategy usando Supabase
/// NOTA: Esta es una implementación stub. Disponible en v2.0
final class SupabaseAuthProviderStrategy: AuthProviderStrategy {

    // MARK: - Properties

    private let url: String
    private let anonKey: String
    private let logger: LoggerProtocol

    // MARK: - Initialization

    init(url: String, anonKey: String, logger: LoggerProtocol) {
        self.url = url
        self.anonKey = anonKey
        self.logger = logger
    }

    // MARK: - AuthProviderStrategy Implementation (STUBS)

    var currentUserId: String? {
        fatalError("SupabaseAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        fatalError("SupabaseAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        fatalError("SupabaseAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func logout() -> AnyPublisher<Void, Error> {
        fatalError("SupabaseAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func observeAuthState() -> AnyPublisher<User?, Never> {
        fatalError("SupabaseAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }
}
