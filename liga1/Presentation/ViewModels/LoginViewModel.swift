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
                
                // Usar NotificationCenter como mecanismo principal para la navegación
                DispatchQueue.main.async {
                    Logger.shared.info("📢 Publicando notificación de login exitoso")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LoginSuccessful"),
                        object: nil,
                        userInfo: ["source": "email"]
                    )
                    
                    // También intentar usar el delegate si está disponible
                    if let delegate = self.coordinatorDelegate {
                        Logger.shared.info("📱 También notificando al coordinator via delegate")
                        delegate.loginViewModelDidLogin(self)
                    } else {
                        Logger.shared.warning("⚠️ coordinatorDelegate es nil, usando solo NotificationCenter")
                    }
                }
            }
            .store(in: &cancellables)
    }

    func signInWithGoogle() {
        Logger.shared.info("🔐 LoginViewModel: signInWithGoogle llamado")
        if let delegate = delegate {
            Logger.shared.info("✅ LoginViewModel: Delegate configurado, solicitando presentación de Google Sign In")
            delegate.loginViewModelNeedsGoogleSignInPresentation(self)
        } else {
            Logger.shared.error("❌ LoginViewModel: delegate es nil - no se puede presentar Google Sign In", error: nil)
            error = "Error de configuración. Por favor intenta de nuevo."
        }
    }

    func performGoogleSignIn(presentingViewController: UIViewController) {
        isLoading = true
        error = nil

        Logger.shared.info("🔐 Iniciando login con Google")
        Logger.shared.info("🔗 Verificando coordinatorDelegate antes de iniciar: \(coordinatorDelegate != nil ? "✅ configurado" : "❌ nil")")
        
        loginUseCase.executeWithGoogle(presentingViewController: presentingViewController)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("❌ Google Sign In failed", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                Logger.shared.info("✅ Login exitoso con Google")
                
                // Usar NotificationCenter como mecanismo principal para la navegación
                // Esto es más robusto que el delegate porque no depende de referencias débiles
                DispatchQueue.main.async {
                    Logger.shared.info("📢 Publicando notificación de login exitoso")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LoginSuccessful"),
                        object: nil,
                        userInfo: ["source": "google"]
                    )
                    
                    // También intentar usar el delegate si está disponible
                    if let delegate = self.coordinatorDelegate {
                        Logger.shared.info("📱 También notificando al coordinator via delegate")
                        delegate.loginViewModelDidLogin(self)
                    } else {
                        Logger.shared.warning("⚠️ coordinatorDelegate es nil, usando solo NotificationCenter")
                    }
                }
            }
            .store(in: &cancellables)
    }

    func clearError() {
        error = nil
    }
}
