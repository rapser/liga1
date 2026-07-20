//
//  LoginWithGoogleUseCase.swift
//  liga1
//
//  Domain/UseCases/Auth: Orquesta obtención de credencial Google + autenticación.
//

import Foundation
import Combine

protocol LoginWithGoogleUseCaseProtocol {
    func execute(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<User, Error>
}

final class LoginWithGoogleUseCase: LoginWithGoogleUseCaseProtocol {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(credentialProvider: GoogleCredentialProvider) -> AnyPublisher<User, Error> {
        credentialProvider.provideCredential()
            .flatMap { [authService] credential in
                authService.signInWithGoogle(credential: credential)
            }
            .eraseToAnyPublisher()
    }
}
