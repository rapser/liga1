//
//  LoginViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
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
        // Validación básica
        guard !email.isEmpty, !password.isEmpty else {
            error = "Por favor completa todos los campos"
            return
        }
        
        isLoading = true
        error = nil

        Logger.shared.info("🔐 Iniciando login con email: \(email)")
        
        loginUseCase.execute(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("❌ Login failed for email: \(email)", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                Logger.shared.info("✅ Login exitoso con email/password")
                
                // Asegurar que la navegación se haga en el hilo principal
                DispatchQueue.main.async {
                    if let delegate = self.coordinatorDelegate {
                        Logger.shared.info("📱 Notificando al coordinator sobre login exitoso")
                        delegate.loginViewModelDidLogin(self)
                    } else {
                        Logger.shared.error("❌ coordinatorDelegate es nil - no se puede navegar al home", error: nil)
                        // Intentar navegar directamente si el delegate no está configurado
                        Logger.shared.warning("⚠️ Intentando navegar sin delegate - esto no debería pasar")
                    }
                }
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
