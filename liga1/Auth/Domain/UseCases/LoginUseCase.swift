//
//  LoginUseCase.swift
//  liga1
//
//  Auth/Domain: use case de login (sin UIKit).
//  Refactored on 31/01/26 to use AuthRepository.
//

import Foundation
import Combine

/// Use Case para realizar login (Domain sin UIKit).
public protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) -> AnyPublisher<User, Error>
    func executeWithGoogle(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<User, Error>
}

public final class LoginUseCase: LoginUseCaseProtocol {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(email: String, password: String) -> AnyPublisher<User, Error> {
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
        return authRepository.login(email: email, password: password)
    }

    public func executeWithGoogle(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<User, Error> {
        return credentialProvider.provideCredential()
            .flatMap { [weak self] credential -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail<User, Error>(
                        error: NSError(domain: "LoginUseCase", code: -1, userInfo: nil)
                    ).eraseToAnyPublisher()
                }
                return self.authRepository.signInWithGoogle(credential: credential)
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
