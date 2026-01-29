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
        
        // Suscribirse a notificaciones como fallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccessfulNotification),
            name: NSNotification.Name("LoginSuccessful"),
            object: nil
        )
        
        navigationController.setViewControllers([loginVC], animated: false)
    }
    
    @objc private func handleLoginSuccessfulNotification(_ notification: Notification) {
        didFinishLogin()
    }
    
    deinit {
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
    }

    func loginViewModelDidLogin(_ viewModel: LoginViewModel) {
        didFinishLogin()
    }
}
