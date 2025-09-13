//
//  MainTabBarController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        let homeVC = HomeViewController()
        let torneoVC = TorneoViewController()
        let partidoVC = PartidoViewController()
        let perfilVC = ProfileViewController()
        homeVC.view.backgroundColor = .white
        torneoVC.view.backgroundColor = .white
        perfilVC.view.backgroundColor = .white
        homeVC.title = "Home"
        torneoVC.title = "Torneo"
        perfilVC.title = "Mi Perfil"
        
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let torneoNavController = UINavigationController(rootViewController: torneoVC)
        let partidoNavController = UINavigationController(rootViewController: partidoVC)
        let perfilNavController = UINavigationController(rootViewController: perfilVC)

        homeVC.tabBarItem = UITabBarItem(title: "home", image: UIImage(systemName: "house"), tag: 0)
        torneoVC.tabBarItem = UITabBarItem(title: "torneo", image: UIImage(systemName: "chart.bar.doc.horizontal"), tag: 1)
        partidoVC.tabBarItem = UITabBarItem(title: "partido", image: UIImage(systemName: "figure.soccer"), tag: 2)
        perfilVC.tabBarItem = UITabBarItem(title: "perfil", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeNavController, torneoNavController, partidoNavController, perfilNavController]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}

