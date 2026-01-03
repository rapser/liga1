//
//  LogoutUseCase.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine

/// Use Case para realizar logout
protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, Error>
}

class LogoutUseCase: LogoutUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute() -> AnyPublisher<Void, Error> {
        return authService.logout()
    }
}
