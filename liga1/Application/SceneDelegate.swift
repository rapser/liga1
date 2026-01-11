//
//  SceneDelegate.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

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

        // Cargar preferencia de tema guardada (o usar automático por defecto)
        let savedStyle = UserDefaults.standard.integer(forKey: "userInterfaceStyle")
        window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: savedStyle) ?? .unspecified

        // Crear DIContainer
        let container = DIContainer.shared

        // Configurar SessionManager
        SessionManager.shared.configure(with: window, container: container)

        // Iniciar AppCoordinator
        let appCoordinator = container.makeAppCoordinator(window: window)
        self.appCoordinator = appCoordinator
        appCoordinator.start()

        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

