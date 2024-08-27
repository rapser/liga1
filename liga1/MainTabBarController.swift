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
        
        // Configuración del fondo blanco para la tabBar
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        // Configurar los items de la tabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white // Fondo blanco
        
        // Aplicar la apariencia al tabBar
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Crear los view controllers
        let homeVC = HomeViewController()
        let torneoVC = TorneoViewController()
        let partidoVC = PartidoViewController()
        let perfilVC = PerfilViewController()
        homeVC.view.backgroundColor = .white
        torneoVC.view.backgroundColor = .white
        homeVC.title = "Home"
        torneoVC.title = "Torneo"
        
        // Configurar los navigation controllers
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let torneoNavController = UINavigationController(rootViewController: torneoVC)
        let partidoNavController = UINavigationController(rootViewController: partidoVC)
        let perfilNavController = UINavigationController(rootViewController: perfilVC)

        // Configurar los items de la tabBar
        homeVC.tabBarItem = UITabBarItem(title: "home", image: UIImage(systemName: "house"), tag: 0)
        torneoVC.tabBarItem = UITabBarItem(title: "torneo", image: UIImage(systemName: "chart.bar.doc.horizontal"), tag: 1)
        partidoVC.tabBarItem = UITabBarItem(title: "partido", image: UIImage(systemName: "figure.soccer"), tag: 2)
        perfilVC.tabBarItem = UITabBarItem(title: "perfil", image: UIImage(systemName: "person"), tag: 3)
        
        // Asignar los view controllers al tab bar controller
        viewControllers = [homeNavController, torneoNavController, partidoNavController, perfilNavController]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Asegurarse de que el color blanco se aplique correctamente
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}

