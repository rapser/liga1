//
//  AppRouter.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import FirebaseAuth

final class AppRouter {
    
    static let shared = AppRouter()
    private init() {}
    
    weak var window: UIWindow?
    
    func configure(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - Navegación inicial
    func setInitialViewController() {
        guard let window = window else { return }
        
        if Auth.auth().currentUser != nil {
            let mainTabBarController = MainTabBarController()
            window.rootViewController = mainTabBarController
        } else {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            window.rootViewController = nav
        }
    }
    
    // MARK: - Cambio de root
    func changeRootViewController(to viewController: UIViewController,
                                  animated: Bool = true) {
        guard let window = window else { return }
        let nav = UINavigationController(rootViewController: viewController)
        
        if animated {
            UIView.transition(with: window,
                              duration: 0.5,
                              options: .transitionFlipFromLeft,
                              animations: {
                window.rootViewController = nav
            }, completion: nil)
        } else {
            window.rootViewController = nav
        }
    }
}
