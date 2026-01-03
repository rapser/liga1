//
//  AppCoordinator.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import UIKit
import FirebaseAuth

/// Coordinator principal de la aplicación
/// Maneja la navegación de alto nivel (Login vs Main)
final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    private let container: DIContainer

    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start() {
        // Verificar si hay usuario autenticado
        if Auth.auth().currentUser != nil {
            showMainFlow()
        } else {
            showLoginFlow()
        }
    }

    func showLoginFlow() {
        let loginCoordinator = container.makeLoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        addChildCoordinator(loginCoordinator)
        window.rootViewController = navigationController
        loginCoordinator.start()
    }

    func showMainFlow() {
        let mainTabBar = MainTabBarController(container: container)
        window.rootViewController = mainTabBar
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidFinish(_ coordinator: LoginCoordinator) {
        removeChildCoordinator(coordinator)
        showMainFlow()
    }
}
