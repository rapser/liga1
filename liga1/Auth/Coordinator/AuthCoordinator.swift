//
//  AuthCoordinator.swift
//  liga1
//
//  Auth/Coordinator: Coordinador para el flujo de autenticación.
//  Created on 31/01/26.
//

import Foundation
import UIKit

/// Protocolo para delegar eventos del coordinador de autenticación
public protocol AuthCoordinatorDelegate: AnyObject {
    /// Se llama cuando el usuario completa el login exitosamente
    func authCoordinatorDidLogin(_ coordinator: AuthCoordinator, user: User)

    /// Se llama cuando el usuario cancela el flujo de autenticación
    func authCoordinatorDidCancel(_ coordinator: AuthCoordinator)
}

/// Coordinador para manejar el flujo de autenticación
public final class AuthCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let diContainer: AuthDIContainer
    public weak var delegate: AuthCoordinatorDelegate?

    // MARK: - Initialization

    public init(
        navigationController: UINavigationController,
        diContainer: AuthDIContainer
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    // MARK: - Public Methods

    /// Inicia el flujo de autenticación mostrando la pantalla de login
    public func start() {
        let loginVC = diContainer.makeLoginViewController(
            presentingViewController: navigationController
        )
        loginVC.delegate = self
        navigationController.pushViewController(loginVC, animated: true)
    }

    /// Finaliza el flujo de autenticación y notifica al delegado
    private func finish(with user: User) {
        delegate?.authCoordinatorDidLogin(self, user: user)
    }

    /// Cancela el flujo de autenticación
    private func cancel() {
        delegate?.authCoordinatorDidCancel(self)
    }
}

// MARK: - LoginViewControllerDelegate

extension AuthCoordinator: LoginViewControllerDelegate {
    func loginViewControllerDidLogin(_ viewController: LoginViewController, user: User) {
        finish(with: user)
    }

    func loginViewControllerDidCancel(_ viewController: LoginViewController) {
        cancel()
    }
}

// MARK: - LoginViewControllerDelegate Protocol

/// Protocolo para comunicar eventos desde LoginViewController
public protocol LoginViewControllerDelegate: AnyObject {
    func loginViewControllerDidLogin(_ viewController: LoginViewController, user: User)
    func loginViewControllerDidCancel(_ viewController: LoginViewController)
}
