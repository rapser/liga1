//
//  MainTabBarController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBarAppearance()
        configureTabBarAppearance()

        // Configuración de los tabs
        let homeVC = HomeViewController()
        homeVC.title = "Home"

        let torneoVC = TorneoViewController()
        torneoVC.title = "Torneo"

        let favoritosVC = FavoritosViewController()
        favoritosVC.title = "Favoritos"

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

        let favoritosNav = createNavController(
            rootViewController: favoritosVC,
            title: "favoritos",
            imageSystemName: "star"
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

        viewControllers = [homeNav, torneoNav, favoritosNav, newsNav, perfilNav]
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .liga1Red
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground

        // Configurar color del item seleccionado (rojo Liga 1)
        let selectedItemAppearance = UITabBarItemAppearance()
        selectedItemAppearance.selected.iconColor = .liga1Red
        selectedItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.liga1Red]

        appearance.stackedLayoutAppearance = selectedItemAppearance
        appearance.inlineLayoutAppearance = selectedItemAppearance
        appearance.compactInlineLayoutAppearance = selectedItemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        tabBar.tintColor = .liga1Red // Color para items seleccionados
        tabBar.unselectedItemTintColor = .systemGray // Color para items no seleccionados
    }
    
    private func createNavController(rootViewController: UIViewController,
                                     title: String,
                                     imageSystemName: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.navigationBar.prefersLargeTitles = true
        rootViewController.view.backgroundColor = .systemBackground
        rootViewController.tabBarItem = UITabBarItem(title: title,
                                                     image: UIImage(systemName: imageSystemName),
                                                     tag: 0)
        return nav
    }
}
