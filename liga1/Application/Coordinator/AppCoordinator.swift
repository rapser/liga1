//
//  AppCoordinator.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
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
        
        // Suscribirse a notificaciones de login y logout
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccessfulNotification),
            name: NSNotification.Name("LoginSuccessful"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogoutSuccessfulNotification),
            name: NSNotification.Name("LogoutSuccessful"),
            object: nil
        )
    }
    
    @objc private func handleLogoutSuccessfulNotification(_ notification: Notification) {
        
        // Limpiar todos los child coordinators
        childCoordinators.removeAll()
        
        // Verificar que NO haya un usuario autenticado
        if Auth.auth().currentUser != nil {
            Logger.shared.warning("⚠️ AppCoordinator: Aún hay usuario autenticado después del logout")
            // Intentar cerrar sesión nuevamente
            do {
                try Auth.auth().signOut()
            } catch {
                Logger.shared.error("❌ AppCoordinator: Error al cerrar sesión forzadamente", error: error)
            }
        }
        
        // Navegar al LoginFlow
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showLoginFlow()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        // Verificar si hay usuario autenticado
        if Auth.auth().currentUser != nil {
            showMainFlow()
        } else {
            showLoginFlow()
        }
    }
    
    @objc private func handleLoginSuccessfulNotification(_ notification: Notification) {        
        // Verificar que realmente haya un usuario autenticado
        guard Auth.auth().currentUser != nil else {
            Logger.shared.error("❌ AppCoordinator: No hay usuario autenticado después del login", error: nil)
            return
        }
        
        // Navegar al MainFlow directamente
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showMainFlow()
        }
    }

    func showLoginFlow() {
        
        // Limpiar cualquier child coordinator previo
        childCoordinators.removeAll()
        
        let loginCoordinator = container.makeLoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        addChildCoordinator(loginCoordinator)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        loginCoordinator.start()
        
    }

    func showMainFlow() {
        let mainTabBar = MainTabBarController(container: container)
        window.rootViewController = mainTabBar
        window.makeKeyAndVisible()
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidFinish(_ coordinator: LoginCoordinator) {
        removeChildCoordinator(coordinator)
        
        // Verificar que haya un usuario autenticado antes de navegar
        guard Auth.auth().currentUser != nil else {
            Logger.shared.error("❌ AppCoordinator: No hay usuario autenticado después del login", error: nil)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.showMainFlow()
        }
    }
}
