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
public protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, Error>
}

public final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() -> AnyPublisher<Void, Error> {
        return authRepository.logout()
            .eraseToAnyPublisher()
    }
}
