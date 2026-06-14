//
//  LogoutUseCase.swift
//  liga1
//
//  Domain/UseCases/Auth: Autoridad única para cerrar sesión.
//

import Foundation
import Combine

protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, Error>
}

final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute() -> AnyPublisher<Void, Error> {
        authService.logout()
    }
}
