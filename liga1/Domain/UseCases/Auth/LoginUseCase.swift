//
//  LoginUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine
import UIKit

/// Use Case para realizar login
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) -> AnyPublisher<Void, Error>
    func executeWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<Void, Error>
}

class LoginUseCase: LoginUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(email: String, password: String) -> AnyPublisher<Void, Error> {
        // Validación de negocio
        guard !email.isEmpty, !password.isEmpty else {
            return Fail(error: NSError(
                domain: "LoginUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Por favor completa todos los campos"]
            ))
            .eraseToAnyPublisher()
        }

        // Validación de formato de email
        guard isValidEmail(email) else {
            return Fail(error: NSError(
                domain: "LoginUseCase",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "El formato del email no es válido"]
            ))
            .eraseToAnyPublisher()
        }

        // Delegar la autenticación al servicio
        return authService.login(email: email, password: password)
    }

    func executeWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<Void, Error> {
        return authService.loginWithGoogle(presentingViewController: presentingViewController)
    }

    // MARK: - Private Methods

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
