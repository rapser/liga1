//
//  LogoutUseCase.swift
//  liga1
//
//  Auth/Domain: use case de logout.
//  Refactored on 31/01/26 to use AuthRepository.
//

import Foundation
import Combine

/// Use Case para realizar logout
protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, Error>
}

final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() -> AnyPublisher<Void, Error> {
        return authRepository.logout()
            .eraseToAnyPublisher()
    }
}
