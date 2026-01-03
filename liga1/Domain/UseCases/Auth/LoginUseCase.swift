//
//  LoginUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para realizar login
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) -> AnyPublisher<Void, Error>
}

class LoginUseCase: LoginUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(email: String, password: String) -> AnyPublisher<Void, Error> {
        // Aquí iría la lógica de validación de negocio
        guard !email.isEmpty, !password.isEmpty else {
            return Fail(error: NSError(
                domain: "LoginUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Email y contraseña son requeridos"]
            ))
            .eraseToAnyPublisher()
        }

        // Delegar la autenticación al servicio
        return Future<Void, Error> { _ in
            // La implementación real debería usar authService
            // Por ahora esto es un placeholder
        }
        .eraseToAnyPublisher()
    }
}
