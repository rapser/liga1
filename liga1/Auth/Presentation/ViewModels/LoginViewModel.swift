//
//  LoginViewModel.swift
//  liga1
//
//  Auth/Presentation: ViewModel del flujo de login.
//

import Foundation
import Combine
import UIKit

/// Delegate para comunicar eventos de navegación al Coordinator
protocol LoginViewModelCoordinatorDelegate: AnyObject {
    func loginViewModelDidRequestGoogleSignIn(_ viewModel: LoginViewModel)
    func loginViewModelDidLogin(_ viewModel: LoginViewModel, user: User)
}

/// Delegate para comunicar eventos de UI al ViewController
protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelNeedsGoogleSignInPresentation(_ viewModel: LoginViewModel)
}

final class LoginViewModel {

    // MARK: - Published Properties

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?

    // MARK: - Delegates

    weak var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    weak var delegate: LoginViewModelDelegate?

    // MARK: - Dependencies

    private let loginUseCase: LoginUseCaseProtocol
    private let logger: LoggerProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(loginUseCase: LoginUseCaseProtocol, logger: LoggerProtocol) {
        self.loginUseCase = loginUseCase
        self.logger = logger
    }

    // MARK: - Methods

    func login(email: String, password: String) {
        // Validación básica
        guard !email.isEmpty, !password.isEmpty else {
            error = "Por favor completa todos los campos"
            return
        }

        isLoading = true
        error = nil

        loginUseCase.execute(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.logger.error("❌ Login failed for email: \(email)", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.coordinatorDelegate?.loginViewModelDidLogin(self, user: user)
                }
            }
            .store(in: &cancellables)
    }

    func signInWithGoogle() {
        if let delegate = delegate {
            delegate.loginViewModelNeedsGoogleSignInPresentation(self)
        } else {
            logger.error("❌ LoginViewModel: delegate es nil - no se puede presentar Google Sign In", error: nil)
            error = "Error de configuración. Por favor intenta de nuevo."
        }
    }

    func performGoogleSignIn(presentingViewController: UIViewController) {
        isLoading = true
        error = nil
        let credentialProvider = GoogleCredentialProviderImpl(presentingViewController: presentingViewController)
        loginUseCase.executeWithGoogle(credentialProvider: credentialProvider)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.logger.error("❌ Google Sign In failed", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.coordinatorDelegate?.loginViewModelDidLogin(self, user: user)
                }
            }
            .store(in: &cancellables)
    }

    func clearError() {
        error = nil
    }
}
