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

    fileprivate func showHome() {
        //        let mainTabBarController = MainTabBarController()
        //        window?.rootViewController = mainTabBarController
        //        window?.makeKeyAndVisible()
        
        // Verificar si el usuario está autenticado
        if Auth.auth().currentUser != nil {
            // Usuario autenticado, mostrar TabBar
            let mainTabBarController = MainTabBarController()
            window?.rootViewController = mainTabBarController
        } else {
            // No autenticado, mostrar pantalla de login
            let loginViewController = LoginViewController()
            window?.rootViewController = loginViewController
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        showHome()
        window?.makeKeyAndVisible()
        
        return true
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

}

