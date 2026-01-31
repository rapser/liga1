//
//  LoginUseCase.swift
//  liga1
//
//  Auth/Domain: use case de login (sin UIKit).
//

import Foundation
import Combine

/// Use Case para realizar login (Domain sin UIKit).
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) -> AnyPublisher<Void, Error>
    func executeWithGoogle(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<Void, Error>
}

class LoginUseCase: LoginUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(email: String, password: String) -> AnyPublisher<Void, Error> {
        guard !email.isEmpty, !password.isEmpty else {
            return Fail(error: NSError(
                domain: "LoginUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Por favor completa todos los campos"]
            ))
            .eraseToAnyPublisher()
        }
        guard isValidEmail(email) else {
            return Fail(error: NSError(
                domain: "LoginUseCase",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "El formato del email no es válido"]
            ))
            .eraseToAnyPublisher()
        }
        return authService.login(email: email, password: password)
    }

    func executeWithGoogle(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<Void, Error> {
        return credentialProvider.provideCredential()
            .flatMap { [weak self] credential -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail<Void, Error>(error: NSError(domain: "LoginUseCase", code: -1, userInfo: nil)).eraseToAnyPublisher()
                }
                return self.authService.signInWithGoogle(credential: credential)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
