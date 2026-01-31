//
//  AuthDIContainer.swift
//  liga1
//
//  Auth/DI: Contenedor de inyección de dependencias para el módulo Auth.
//  Created on 31/01/26.
//

import Foundation
import UIKit

/// Contenedor de inyección de dependencias para el módulo de autenticación
public class AuthDIContainer {

    // MARK: - Dependencies

    private let logger: LoggerProtocol

    // MARK: - Initialization

    public init(logger: LoggerProtocol) {
        self.logger = logger
    }

    // MARK: - Repositories

    func makeAuthRepository() -> AuthRepository {
        return AuthService(logger: logger)
    }

    // MARK: - Use Cases

    func makeLoginUseCase() -> LoginUseCaseProtocol {
        return LoginUseCase(authRepository: makeAuthRepository())
    }

    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        return LogoutUseCase(authRepository: makeAuthRepository())
    }

    // MARK: - Presentation

    func makeGoogleCredentialProvider(presentingViewController: UIViewController) -> GoogleCredentialProvider {
        return GoogleCredentialProviderImpl(presentingViewController: presentingViewController)
    }

    // MARK: - ViewModels

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            loginUseCase: makeLoginUseCase(),
            logger: logger
        )
    }

    // MARK: - ViewControllers

    func makeLoginViewController(
        presentingViewController: UIViewController
    ) -> LoginViewController {
        let viewModel = makeLoginViewModel()
        let googleCredentialProvider = makeGoogleCredentialProvider(
            presentingViewController: presentingViewController
        )

        let loginVC = LoginViewController(
            viewModel: viewModel,
            googleCredentialProvider: googleCredentialProvider
        )

        return loginVC
    }
}
