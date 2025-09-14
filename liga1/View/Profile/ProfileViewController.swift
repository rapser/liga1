//
//  ProfileViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/10/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    // MARK: - Modelo de opción
    struct Option {
        let title: String
        let icon: UIImage?
        let subtitle: String? // Para versión o info adicional
        let action: (() -> Void)?
    }

    struct Section {
        let title: String
        let options: [Option]
    }

    var sections: [Section] = []

    // MARK: - Tabla
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSections()
        setupTableView()
    }

    // MARK: - Configuración secciones
    private func setupSections() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
        let versionString = "\(appVersion) (\(buildNumber))"

        sections = [
            Section(title: "Notificaciones Push", options: [
                Option(title: "Ajustes de notificaciones", icon: UIImage(systemName: "bell.fill"), subtitle: nil, action: {
                    print("Abrir ajustes de notificaciones")
                })
            ]),
            Section(title: "Usuario", options: [
                Option(title: "Nombre de usuario", icon: UIImage(systemName: "person.fill"), subtitle: nil, action: {
                    print("Editar nombre de usuario")
                }),
                Option(title: "Cerrar Sesión", icon: UIImage(systemName: "arrow.backward.circle.fill"), subtitle: nil, action: { [weak self] in
                    self?.showLogoutConfirmation()
                })
            ]),
            Section(title: "Tema", options: [
                Option(title: "Modo Claro / Modo Oscuro", icon: UIImage(systemName: "circle.lefthalf.fill"), subtitle: nil, action: { [weak self] in
                    self?.showThemeBottomSheet()
                })
            ]),
            Section(title: "Otros", options: [
                Option(title: "Envía tus comentarios", icon: UIImage(systemName: "envelope.fill"), subtitle: nil, action: {
                    print("Enviar feedback")
                }),
                Option(title: "Condiciones de uso", icon: UIImage(systemName: "doc.text.fill"), subtitle: nil, action: {
                    print("Mostrar condiciones de uso")
                }),
                Option(title: "Políticas de privacidad", icon: UIImage(systemName: "lock.shield.fill"), subtitle: nil, action: {
                    print("Mostrar políticas de privacidad")
                }),
                Option(title: "Ajustes de privacidad", icon: UIImage(systemName: "gearshape.fill"), subtitle: nil, action: {
                    print("Abrir ajustes de privacidad")
                }),
                Option(title: "Versión", icon: nil, subtitle: versionString, action: nil)
            ])
        ]
    }

    // MARK: - Configuración Tabla
    private func setupTableView() {
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Bottom Sheet Tema
    private func showThemeBottomSheet() {
        let alertController = UIAlertController(title: "Selecciona un tema",
                                                message: nil,
                                                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Claro", style: .default, handler: { _ in
            self.overrideUserInterfaceStyle = .light
            print("Modo Claro activado")
        }))

        alertController.addAction(UIAlertAction(title: "Oscuro", style: .default, handler: { _ in
            self.overrideUserInterfaceStyle = .dark
            print("Modo Oscuro activado")
        }))

        alertController.addAction(UIAlertAction(title: "Automático", style: .default, handler: { _ in
            self.overrideUserInterfaceStyle = .unspecified
            print("Modo Automático activado")
        }))

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        if let sheet = alertController.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Logout
    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Cerrar Sesión",
                                      message: "¿Estás seguro de que deseas cerrar sesión?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive, handler: { [weak self] _ in
            self?.logout()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func logout() {
        do {
            try Auth.auth().signOut()

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let loginViewController = LoginViewController()
                
                window.rootViewController = loginViewController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }

            print("Usuario cerrado sesión.")
        } catch let error {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
