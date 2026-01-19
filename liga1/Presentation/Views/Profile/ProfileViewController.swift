//
//  ProfileViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/10/24.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {

    // MARK: - Properties

    let viewModel: ProfileViewModel
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Tabla
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.prepareForAutoLayout()
        return tableView
    }()

    // MARK: - Initialization

    init(viewModel: ProfileViewModel, container: DIContainer) {
        self.viewModel = viewModel
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:container:)")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView
            .addTo(view)
            .pinTop(useSafeArea: true)
            .pinBottom(useSafeArea: true)
            .pinHorizontal()

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)

        viewModel.$logoutSuccessful
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigateToLogin()
            }
            .store(in: &cancellables)
    }

    // MARK: - Internal Methods

    func handleAction(_ action: ProfileViewModel.ProfileAction) {
        switch action {
        case .notification:
            // TODO: Implementar ajustes de notificaciones
            break
        case .editUsername:
            // TODO: Implementar edición de nombre de usuario
            break
        case .logout:
            showLogoutConfirmation()
        case .feedback:
            // TODO: Implementar envío de feedback
            break
        case .terms:
            // TODO: Implementar vista de condiciones de uso
            break
        case .privacy:
            // TODO: Implementar vista de políticas de privacidad
            break
        case .privacySettings:
            // TODO: Implementar ajustes de privacidad
            break
        case .registrarPartidos:
            navigateToRegistrarPartidos()
        case .none:
            break
        }
    }

    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Cerrar Sesión",
                                      message: "¿Estás seguro de que deseas cerrar sesión?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.logout()
        }))

        present(alert, animated: true, completion: nil)
    }

    private func navigateToLogin() {
        Logger.shared.info("🚪 ProfileViewController: Navegando al login después de cerrar sesión")
        
        // Publicar notificación para que AppCoordinator maneje la navegación
        NotificationCenter.default.post(
            name: NSNotification.Name("LogoutSuccessful"),
            object: nil
        )
        
        // También navegar directamente como fallback
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let loginCoordinator = self.container.makeLoginCoordinator(navigationController: UINavigationController())
                loginCoordinator.delegate = nil // No necesitamos delegate para logout
                loginCoordinator.start()
                
                window.rootViewController = loginCoordinator.navigationController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
                Logger.shared.info("✅ ProfileViewController: Navegación al login completada")
            }
        }
    }

    private func navigateToRegistrarPartidos() {
        let registrarPartidosVC = container.makeRegistrarPartidosViewController()
        navigationController?.pushViewController(registrarPartidosVC, animated: true)
    }

}
