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
        navigationController.setViewControllers([loginVC], animated: false)
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
        Logger.shared.info("Login successful, finishing login flow")
        didFinishLogin()
    }
}
