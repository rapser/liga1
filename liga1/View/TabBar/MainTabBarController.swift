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
        
        configureTabBarAppearance()
        
        // Configuración de los tabs
        let homeVC = HomeViewController()
        homeVC.title = "Home"
        
        let torneoVC = TorneoViewController()
        torneoVC.title = "Torneo"
        
        let partidoVC = PartidoViewController()
        partidoVC.title = "Partido"
        
        let newsVC = NewsViewController()
        newsVC.title = "Noticias"
        
        let perfilVC = ProfileViewController()
        perfilVC.title = "Mi Perfil"
        
        // Crear NavControllers con estilo Large Title
        let homeNav = createNavController(
            rootViewController: homeVC,
            title: "home",
            imageSystemName: "house"
        )
        
        let torneoNav = createNavController(
            rootViewController: torneoVC,
            title: "torneo",
            imageSystemName: "chart.bar.doc.horizontal"
        )
        
        let partidoNav = createNavController(
            rootViewController: partidoVC,
            title: "partido",
            imageSystemName: "figure.soccer"
        )
        
        let newsNav = createNavController(
            rootViewController: newsVC,
            title: "noticias",
            imageSystemName: "newspaper")
        
        let perfilNav = createNavController(
            rootViewController: perfilVC,
            title: "perfil",
            imageSystemName: "person"
        )
        
        viewControllers = [homeNav, torneoNav, partidoNav, newsNav, perfilNav]
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        tabBar.barTintColor = .white
    }
    
    private func createNavController(rootViewController: UIViewController,
                                     title: String,
                                     imageSystemName: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.navigationBar.prefersLargeTitles = true
        rootViewController.view.backgroundColor = .white
        rootViewController.tabBarItem = UITabBarItem(title: title,
                                                     image: UIImage(systemName: imageSystemName),
                                                     tag: 0)
        return nav
    }
}


//class MainTabBarController: UITabBarController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tabBar.barTintColor = .white
//        tabBar.isTranslucent = false
//        
//        let appearance = UITabBarAppearance()
//        appearance.configureWithDefaultBackground()
//        appearance.backgroundColor = .white
//        
//        tabBar.standardAppearance = appearance
//        tabBar.scrollEdgeAppearance = appearance
//        
//        let homeVC = HomeViewController()
//        let torneoVC = TorneoViewController()
//        let partidoVC = PartidoViewController()
//        let perfilVC = ProfileViewController()
//        homeVC.view.backgroundColor = .white
//        torneoVC.view.backgroundColor = .white
//        perfilVC.view.backgroundColor = .white
//        homeVC.title = "Home"
//        torneoVC.title = "Torneo"
//        perfilVC.title = "Mi Perfil"
//        
//        let homeNavController = UINavigationController(rootViewController: homeVC)
//        let torneoNavController = UINavigationController(rootViewController: torneoVC)
//        let partidoNavController = UINavigationController(rootViewController: partidoVC)
//        let perfilNavController = UINavigationController(rootViewController: perfilVC)
//
//        homeVC.tabBarItem = UITabBarItem(title: "home", image: UIImage(systemName: "house"), tag: 0)
//        torneoVC.tabBarItem = UITabBarItem(title: "torneo", image: UIImage(systemName: "chart.bar.doc.horizontal"), tag: 1)
//        partidoVC.tabBarItem = UITabBarItem(title: "partido", image: UIImage(systemName: "figure.soccer"), tag: 2)
//        perfilVC.tabBarItem = UITabBarItem(title: "perfil", image: UIImage(systemName: "person"), tag: 3)
//        
//        viewControllers = [homeNavController, torneoNavController, partidoNavController, perfilNavController]
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        tabBar.barTintColor = .white
//        tabBar.isTranslucent = false
//    }
//}

