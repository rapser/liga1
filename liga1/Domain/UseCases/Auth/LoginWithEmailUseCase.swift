//
//  LoginWithEmailUseCase.swift
//  liga1
//
//  Domain/UseCases/Auth: Orquesta validación + autenticación por email.
//

import Foundation
import Combine

protocol LoginWithEmailUseCaseProtocol {
    func execute(email: String, password: String) -> AnyPublisher<User, Error>
}

final class LoginWithEmailUseCase: LoginWithEmailUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(email: String, password: String) -> AnyPublisher<User, Error> {
        do {
            try LoginValidator.validate(email: email, password: password)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return authService.login(email: email, password: password)
    }
}
