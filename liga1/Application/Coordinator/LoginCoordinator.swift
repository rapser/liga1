//
//  LoginCoordinator.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func loginCoordinatorDidFinish(_ coordinator: LoginCoordinator)
}

/// Coordinator para el flujo de login
final class LoginCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: LoginCoordinatorDelegate?
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let loginVC = container.makeLoginViewController()
        loginVC.viewModel.coordinatorDelegate = self
        Logger.shared.info("🔗 LoginCoordinator: coordinatorDelegate configurado")
        Logger.shared.info("🔗 LoginCoordinator: Verificando delegate después de configurar: \(loginVC.viewModel.coordinatorDelegate != nil ? "✅ configurado" : "❌ nil")")
        
        // Suscribirse a notificaciones como fallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccessfulNotification),
            name: NSNotification.Name("LoginSuccessful"),
            object: nil
        )
        
        navigationController.setViewControllers([loginVC], animated: false)
        
        // Verificar nuevamente después de agregar al navigation controller
        DispatchQueue.main.async {
            Logger.shared.info("🔗 LoginCoordinator: Verificando delegate después de agregar al navigation: \(loginVC.viewModel.coordinatorDelegate != nil ? "✅ configurado" : "❌ nil")")
        }
    }
    
    @objc private func handleLoginSuccessfulNotification(_ notification: Notification) {
        let source = notification.userInfo?["source"] as? String ?? "unknown"
        Logger.shared.info("📢 LoginCoordinator: Recibida notificación de login exitoso (source: \(source))")
        didFinishLogin()
    }
    
    deinit {
        Logger.shared.info("🗑️ LoginCoordinator: Deallocando")
        NotificationCenter.default.removeObserver(self)
    }

    func didFinishLogin() {
        delegate?.loginCoordinatorDidFinish(self)
    }
}

// MARK: - LoginViewModelCoordinatorDelegate

extension LoginCoordinator: LoginViewModelCoordinatorDelegate {
    func loginViewModelDidRequestGoogleSignIn(_ viewModel: LoginViewModel) {
        // El ViewController maneja la presentación real de Google Sign In UI
        // Este método puede ser usado para analytics o logging
        Logger.shared.debug("Google Sign In requested via coordinator")
    }

    func loginViewModelDidLogin(_ viewModel: LoginViewModel) {
        Logger.shared.info("✅ LoginCoordinator: Login exitoso, finalizando flujo de login")
        didFinishLogin()
    }
}
