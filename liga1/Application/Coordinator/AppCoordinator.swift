//
//  AppCoordinator.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import UIKit
import Combine

/// Coordinator principal de la aplicación
/// Maneja la navegación de alto nivel (Login vs Main)
final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    private let container: DIContainer
    private let eventBus: AppEventBusProtocol
    private let logger: LoggerProtocol
    private var cancellables = Set<AnyCancellable>()
    private var hasReceivedInitialAuthState = false

    init(
        window: UIWindow,
        container: DIContainer,
        eventBus: AppEventBusProtocol,
        logger: LoggerProtocol
    ) {
        self.window = window
        self.container = container
        self.eventBus = eventBus
        self.logger = logger
        self.navigationController = UINavigationController()

        // Observar eventos del EventBus
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

        // Observar cambios en el estado de autenticación
        AuthManager.shared.observeAuthState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.handleAuthStateChange(user: user)
            }
            .store(in: &cancellables)
    }

    private func handleAuthStateChange(user: User?) {
        // Marcar que hemos recibido el estado inicial
        let isInitialState = !hasReceivedInitialAuthState
        hasReceivedInitialAuthState = true

        if user != nil {
            // Usuario autenticado - mostrar main flow si aún no está mostrándose
            if !(window.rootViewController is MainTabBarController) {
                logger.info(isInitialState ? "✅ Estado inicial: Usuario autenticado - navegando a Main Flow" : "✅ Usuario autenticado - navegando a Main Flow")
                childCoordinators.removeAll()
                showMainFlow()
            }
        } else {
            // No hay usuario - mostrar login flow si aún no está mostrándose
            if !(window.rootViewController is UINavigationController) {
                logger.info(isInitialState ? "ℹ️ Estado inicial: No hay usuario - navegando a Login Flow" : "ℹ️ No hay usuario autenticado - navegando a Login Flow")
                childCoordinators.removeAll()
                showLoginFlow()
            }
        }
    }

    private func handleLoginSuccess() {
        // Este método ahora es manejado principalmente por observeAuthState
        // Pero lo mantenemos para limpieza de coordinadores
        childCoordinators.removeAll()
        logger.info("📱 Login exitoso recibido via EventBus")
    }

    private func handleLogoutRequested() {
        // Este método ya no navega directamente - el observeAuthState se encarga
        // Solo limpiamos los coordinadores
        childCoordinators.removeAll()
        logger.info("📱 Logout solicitado - la navegación será manejada por observeAuthState")
    }

    func start() {
        // Mostrar una pantalla de carga mientras esperamos el estado de autenticación
        // El observeAuthState() navegará a login o main según corresponda
        showLoadingScreen()
        logger.info("🚀 AppCoordinator iniciado - esperando estado de autenticación")
    }

    private func showLoadingScreen() {
        let loadingVC = UIViewController()
        loadingVC.view.backgroundColor = .appBackground

        // Agregar activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .liga1Red
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()

        loadingVC.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingVC.view.centerYAnchor)
        ])

        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
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
