//
//  RESTAuthProviderStrategy.swift
//  liga1
//
//  AuthKit/Providers/REST: Implementación de AuthProviderStrategy para REST API.
//  STUB - Preparado para v2.0 con SSL Pinning - Created on 15/02/26.
//

import Foundation
import Combine

/// Implementación de AuthProviderStrategy usando REST API con SSL Pinning opcional
/// NOTA: Esta es una implementación stub. Disponible en v2.0
final class RESTAuthProviderStrategy: AuthProviderStrategy {

    // MARK: - Properties

    private let baseURL: URL
    private let sslPinning: SSLPinningManager?
    private let logger: LoggerProtocol

    // MARK: - Initialization

    init(baseURL: URL, sslPinning: SSLPinningConfig?, logger: LoggerProtocol) {
        self.baseURL = baseURL
        self.sslPinning = sslPinning != nil ? SSLPinningManager(config: sslPinning!) : nil
        self.logger = logger
    }

    // MARK: - AuthProviderStrategy Implementation (STUBS)

    var currentUserId: String? {
        fatalError("RESTAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        fatalError("RESTAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func signInWithGoogle(credential: GoogleCredential) -> AnyPublisher<User, Error> {
        fatalError("RESTAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func logout() -> AnyPublisher<Void, Error> {
        fatalError("RESTAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }

    func observeAuthState() -> AnyPublisher<User?, Never> {
        fatalError("RESTAuthProviderStrategy no implementado aún. Disponible en v2.0. Ver README.md")
    }
}
