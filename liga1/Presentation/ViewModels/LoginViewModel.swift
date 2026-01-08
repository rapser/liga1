//
//  LoginViewModel.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine
import UIKit

/// Delegate para comunicar eventos de navegación al Coordinator
protocol LoginViewModelCoordinatorDelegate: AnyObject {
    func loginViewModelDidRequestGoogleSignIn(_ viewModel: LoginViewModel)
    func loginViewModelDidLogin(_ viewModel: LoginViewModel)
}

/// Delegate para comunicar eventos de UI al ViewController
protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelNeedsGoogleSignInPresentation(_ viewModel: LoginViewModel)
}

class LoginViewModel {

    // MARK: - Published Properties

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?

    // MARK: - Delegates

    weak var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    weak var delegate: LoginViewModelDelegate?

    // MARK: - Dependencies

    private let loginUseCase: LoginUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    // MARK: - Public Methods

    func login(email: String, password: String) {
        isLoading = true
        error = nil

        loginUseCase.execute(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Login failed for email: \(email)", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.coordinatorDelegate?.loginViewModelDidLogin(self)
            }
            .store(in: &cancellables)
    }

    func signInWithGoogle() {
        delegate?.loginViewModelNeedsGoogleSignInPresentation(self)
    }

    func performGoogleSignIn(presentingViewController: UIViewController) {
        isLoading = true
        error = nil

        loginUseCase.executeWithGoogle(presentingViewController: presentingViewController)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Google Sign In failed", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.coordinatorDelegate?.loginViewModelDidLogin(self)
            }
            .store(in: &cancellables)
    }

    func clearError() {
        error = nil
    }
}
