//
//  SceneDelegate.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Configurar color de tint global de la app
        window.tintColor = .liga1Red

        // El tema se maneja automáticamente según la configuración del sistema del usuario
        // No se establece overrideUserInterfaceStyle para respetar el tema del dispositivo

        // Crear DIContainer
        let container = DIContainer.shared

        // Configurar SessionManager
        SessionManager.shared.configure(with: window, container: container)

        // Iniciar AppCoordinator
        let appCoordinator = container.makeAppCoordinator(window: window)
        self.appCoordinator = appCoordinator
        appCoordinator.start() // AppCoordinator maneja window.makeKeyAndVisible()

        // Tap en notificación → EventBus → AppCoordinator maneja .navigateToMatch
        let eventBus = container.makeAppEventBus()
        SessionManager.shared.onNotificationTap = { matchId in
            eventBus.publish(.navigateToMatch(matchId: matchId))
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Limpiar badge cuando la escena se vuelve activa
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
            } catch {
                DIContainer.shared.makeLogger().error("Error al limpiar badge", error: error)
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

