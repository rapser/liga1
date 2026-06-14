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
    private let eventBus: AppEventBusProtocol

    init(navigationController: UINavigationController, container: DIContainer, eventBus: AppEventBusProtocol) {
        self.navigationController = navigationController
        self.container = container
        self.eventBus = eventBus
    }

    func start() {
        let loginVC = container.makeLoginViewController(presentingViewController: navigationController)
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
    }

    func loginViewModelDidLogin(_ viewModel: LoginViewModel, user: User) {
        didFinishLogin()
    }
}
