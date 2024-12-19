//
//  ProfileViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/10/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let options = ["Nombre", "Marcadores", "Contacto", "Cerrar Sesión"]
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Acciones para "Nombre"
            print("Seleccionado: Nombre")
        case 1:
            // Acciones para "Marcadores"
            print("Seleccionado: Marcadores")
        case 2:
            // Acciones para "Contacto"
            print("Seleccionado: Contacto")
        case 3:
            // Muestra alerta de confirmación para "Cerrar Sesión"
            showLogoutConfirmation()
        default:
            break
        }
    }
    
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

    // Método de cierre de sesión
    private func logout() {
        do {
            try Auth.auth().signOut()

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // Crear una nueva instancia de LoginViewController
                let loginViewController = LoginViewController()
                
                // Establecer el controlador raíz como el LoginViewController
                window.rootViewController = loginViewController
                window.makeKeyAndVisible()
                
                // Transición suave (opcional)
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }

            print("Usuario cerrado sesión.")
        } catch let error {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

}
