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
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Configurar color de tint global de la app
        window.tintColor = .liga1Red

        // Aplicar modo oscuro por defecto
        window.overrideUserInterfaceStyle = .dark

        // Configurar singletons
        AppRouter.shared.configure(window: window)
        SessionManager.shared.configure(with: window)

        // Mostrar pantalla inicial
        AppRouter.shared.setInitialViewController()
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

