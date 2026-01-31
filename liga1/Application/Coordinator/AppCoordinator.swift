//
//  AppCoordinator.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import UIKit
import FirebaseAuth
import Combine

/// Coordinator principal de la aplicación
/// Maneja la navegación de alto nivel (Login vs Main)
final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    private let container: DIContainer
    private let eventBus: AppEventBusProtocol
    private var cancellables = Set<AnyCancellable>()

    init(window: UIWindow, container: DIContainer, eventBus: AppEventBusProtocol) {
        self.window = window
        self.container = container
        self.eventBus = eventBus
        self.navigationController = UINavigationController()
        eventBus.events()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .loginSuccess:
                    self?.handleLoginSuccess()
                case .logoutRequested:
                    self?.handleLogoutRequested()
                case .navigateToMatch(let matchId):
                    self?.handleNotificationTap(matchId: matchId)
                }
            }
            .store(in: &cancellables)
    }

    private func handleLoginSuccess() {
        childCoordinators.removeAll()
        guard Auth.auth().currentUser != nil else {
            Logger.shared.error("❌ AppCoordinator: No hay usuario autenticado después del login", error: nil)
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.showMainFlow()
        }
    }

    private func handleLogoutRequested() {
        childCoordinators.removeAll()
        if Auth.auth().currentUser != nil {
            Logger.shared.warning("⚠️ AppCoordinator: Aún hay usuario autenticado después del logout")
            do {
                try Auth.auth().signOut()
            } catch {
                Logger.shared.error("❌ AppCoordinator: Error al cerrar sesión forzadamente", error: error)
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showLoginFlow()
        }
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
        childCoordinators.removeAll()
        let loginCoordinator = container.makeLoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        addChildCoordinator(loginCoordinator)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        loginCoordinator.start()
    }

    func showMainFlow() {
        let mainTabBar = container.makeMainTabBarController(eventBus: eventBus)
        window.rootViewController = mainTabBar
        window.makeKeyAndVisible()
    }

    /// Navegación al abrir la app desde un tap en notificación push (matchId).
    func handleNotificationTap(matchId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let mainTabBar = self.window.rootViewController as? MainTabBarController else { return }
            mainTabBar.selectedIndex = 0
        }
    }
}

// MARK: - LoginCoordinatorDelegate (compatibilidad; la lógica principal va por EventBus .loginSuccess)

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidFinish(_ coordinator: LoginCoordinator) {
        removeChildCoordinator(coordinator)
    }
}
