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
    private let authService: AuthServiceProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let logger: LoggerProtocol
    private var cancellables = Set<AnyCancellable>()
    private var hasReceivedInitialAuthState = false

    init(
        window: UIWindow,
        container: DIContainer,
        eventBus: AppEventBusProtocol,
        authService: AuthServiceProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        logger: LoggerProtocol
    ) {
        self.window = window
        self.container = container
        self.eventBus = eventBus
        self.authService = authService
        self.logoutUseCase = logoutUseCase
        self.logger = logger
        self.navigationController = UINavigationController()

        // Observar eventos del EventBus
        eventBus.events()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .logoutRequested:
                    self?.handleLogoutRequested()
                case .sessionExpired:
                    self?.handleSessionExpired()
                case .navigateToMatch(let matchId):
                    self?.handleNotificationTap(matchId: matchId)
                }
            }
            .store(in: &cancellables)

        // Observar cambios en el estado de autenticación (sin acoplar a AuthManager.shared)
        authService.observeAuthState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.handleAuthStateChange(user: user)
            }
            .store(in: &cancellables)
    }

    private func handleAuthStateChange(user: User?) {
        let isInitialState = !hasReceivedInitialAuthState
        hasReceivedInitialAuthState = true

        if user != nil {
            if !(window.rootViewController is MainTabBarController) {
                logger.info(isInitialState ? "✅ Estado inicial: Usuario autenticado - navegando a Main Flow" : "✅ Usuario autenticado - navegando a Main Flow")
                childCoordinators.removeAll()
                showMainFlow()
            }
        } else {
            if isInitialState {
                DispatchQueue.main.async { [weak self] in
                    self?.attemptShowLoginIfStillLoggedOut()
                }
                return
            }
            attemptShowLoginIfStillLoggedOut()
        }
    }

    private func attemptShowLoginIfStillLoggedOut() {
        guard authService.currentUserId == nil else { return }
        if window.rootViewController is UINavigationController { return }
        logger.info("ℹ️ No hay usuario autenticado - navegando a Login Flow")
        childCoordinators.removeAll()
        showLoginFlow()
    }

    private func handleLogoutRequested() {
        childCoordinators.removeAll()
        logger.info("📱 Logout solicitado - la navegación será manejada por observeAuthState")
    }

    private func handleSessionExpired() {
        logger.info("⏰ Sesión expirada por inactividad - ejecutando logout")
        logoutUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("❌ Error al cerrar sesión por inactividad", error: error)
                    }
                    self?.showSessionExpiredAlert()
                },
                receiveValue: { }
            )
            .store(in: &cancellables)
    }

    private func showSessionExpiredAlert() {
        guard let rootVC = window.rootViewController else { return }
        let alert = UIAlertController(
            title: "Sesión Expirada",
            message: "Tu sesión ha terminado por inactividad.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        rootVC.present(alert, animated: true)
    }

    func start() {
        showLoadingScreen()
        logger.info("🚀 AppCoordinator iniciado - esperando estado de autenticación")
    }

    private func showLoadingScreen() {
        let loadingVC = UIViewController()
        loadingVC.view.backgroundColor = .appBackground

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

    func handleNotificationTap(matchId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let mainTabBar = self.window.rootViewController as? MainTabBarController else { return }
            mainTabBar.selectedIndex = 0
        }
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidFinish(_ coordinator: LoginCoordinator) {
        removeChildCoordinator(coordinator)
    }
}
