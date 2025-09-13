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
    var inactivityTimer: Timer?
    let inactivityTimeLimit: TimeInterval = 30
    
    func showTabBar() {
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        showHome()
        window?.makeKeyAndVisible()
    }
    
    fileprivate func showHome() {
        let navigationController = UINavigationController()
        
        if Auth.auth().currentUser != nil {
            let mainTabBarController = MainTabBarController()
            navigationController.viewControllers = [mainTabBarController]
        } else {
            let loginViewController = LoginViewController()
            navigationController.viewControllers = [loginViewController]
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func changeRootViewController(to viewController: UIViewController) {
        guard let window = window else { return }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window.rootViewController = navigationController
        
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
    
    func startInactivityTimer() {
        resetTimer()
    }
    
    func resetTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(timeInterval: inactivityTimeLimit, target: self, selector: #selector(showSessionExpiredAlert), userInfo: nil, repeats: false)
    }
    
    @objc private func showSessionExpiredAlert() {
        guard let rootViewController = window?.rootViewController else { return }
        
        let alertController = UIAlertController(title: "Sesión Expirada",
                                                message: "Tu sesión ha terminado debido a inactividad.",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
            self.logout()
        }))
        
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            let loginViewController = LoginViewController()
            
            if let navController = window?.rootViewController as? UINavigationController {
                navController.setViewControllers([loginViewController], animated: true)
            }
            
            print("Usuario cerrado sesión automáticamente por inactividad.")
        } catch let error {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
}

