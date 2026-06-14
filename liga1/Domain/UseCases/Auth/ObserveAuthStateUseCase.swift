//
//  ObserveAuthStateUseCase.swift
//  liga1
//
//  Domain/UseCases/Auth: Observa cambios en el estado de autenticación.
//

import Foundation
import Combine

protocol ObserveAuthStateUseCaseProtocol {
    func execute() -> AnyPublisher<User?, Never>
}

final class ObserveAuthStateUseCase: ObserveAuthStateUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute() -> AnyPublisher<User?, Never> {
        authService.observeAuthState()
    }
}
