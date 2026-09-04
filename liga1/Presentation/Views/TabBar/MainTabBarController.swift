//
//  MainTabBarController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let container: DIContainer
    private let eventBus: AppEventBusProtocol

    init(container: DIContainer, eventBus: AppEventBusProtocol) {
        self.container = container
        self.eventBus = eventBus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(container:eventBus:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBarAppearance()
        configureTabBarAppearance()

        // Configuración de los tabs
        let homeVC = container.makeHomeViewController()
        // El título se configura en el propio ViewController

        let torneoVC = container.makeTablaViewController()
        torneoVC.title = "Tabla"
        torneoVC.onSimulate = { [weak torneoVC, container] torneo in
            let simulador = container.makeStandingsSimulatorViewController(torneo: torneo)
            torneoVC?.navigationController?.pushViewController(simulador, animated: true)
        }

        // Noticias: fuera del tab bar en el rediseño "Fan Experience".
        // Para reactivarla: descomentar el bloque de `newsNav` y añadirlo a `viewControllers`.
        // let newsVC = container.makeNewsViewController()
        // newsVC.title = "Noticias"

        let perfilVC = container.makeProfileViewController(eventBus: eventBus)
        perfilVC.title = "Ajustes"

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

        // let newsNav = createNavController(
        //     rootViewController: newsVC,
        //     title: "noticias",
        //     imageSystemName: "newspaper")

        let perfilNav = createNavController(
            rootViewController: perfilVC,
            title: "ajustes",
            imageSystemName: "gearshape"
        )

        viewControllers = [homeNav, torneoNav, perfilNav]
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .liga1Red
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground

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
        rootViewController.view.backgroundColor = .appBackground
        rootViewController.tabBarItem = UITabBarItem(title: title,
                                                     image: UIImage(systemName: imageSystemName),
                                                     tag: 0)
        return nav
    }
}
