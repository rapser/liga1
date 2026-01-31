//
//  LogoutUseCase.swift
//  liga1
//
//  Auth/Domain: use case de logout.
//

import Foundation
import Combine

/// Use Case para realizar logout
protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, Error>
}

class LogoutUseCase: LogoutUseCaseProtocol {

    private let authService: AuthServiceProtocol
    private let logger: LoggerProtocol

    init(authService: AuthServiceProtocol, logger: LoggerProtocol) {
        self.authService = authService
        self.logger = logger
    }

    func execute() -> AnyPublisher<Void, Error> {

        return authService.logout()
            .handleEvents(
                receiveOutput: { _ in
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("LogoutUseCase: Failed to logout user", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
