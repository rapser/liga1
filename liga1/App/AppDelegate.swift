//
//  AppDelegate.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func showTabBar() {
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        showHome()
        window?.makeKeyAndVisible()
        
        return true
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
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    var inactivityTimer: Timer?
    let inactivityTimeLimit: TimeInterval = 600
    
    // MARK: - UIApplicationDelegate Methods
    
    func startInactivityTimer() {
        resetTimer()
    }
    
    private func resetTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(timeInterval: inactivityTimeLimit, target: self, selector: #selector(showSessionExpiredAlert), userInfo: nil, repeats: false)
    }
    
    @objc private func showSessionExpiredAlert() {
        logout()
        showAlertForSessionExpiration()
    }
    
    private func showAlertForSessionExpiration() {
        guard let rootViewController = window?.rootViewController else { return }
        
        let alertController = UIAlertController(title: "Sesión Expirada",
                                                message: "Tu sesión ha terminado debido a inactividad.",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
            if let navController = rootViewController as? UINavigationController {
                let loginViewController = LoginViewController()
                navController.setViewControllers([loginViewController], animated: true)
            }
        }))
        
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            print("Usuario cerrado sesión automáticamente por inactividad.")
        } catch let error {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}

