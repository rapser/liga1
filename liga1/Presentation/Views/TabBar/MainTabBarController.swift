//
//  MainTabBarController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(container:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBarAppearance()
        configureTabBarAppearance()

        // Configuración de los tabs
        let homeVC = container.makeHomeViewController()
        homeVC.title = "Inicio"

        let torneoVC = container.makeTablaViewController()
        torneoVC.title = "Tabla"

        let favoritosVC = container.makeFavoritosViewController()
        favoritosVC.title = "Favoritos"

        let newsVC = container.makeNewsViewController()
        newsVC.title = "Noticias"

        let perfilVC = container.makeProfileViewController()
        perfilVC.title = "Mi Perfil"

        // Crear NavControllers con estilo Large Title
        let homeNav = createNavController(
            rootViewController: homeVC,
            title: "inicio",
            imageSystemName: "house"
        )

        let torneoNav = createNavController(
            rootViewController: torneoVC,
            title: "tabla",
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
