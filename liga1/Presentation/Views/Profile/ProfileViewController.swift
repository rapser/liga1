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
        case .theme:
            showThemeBottomSheet()
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

    private func showThemeBottomSheet() {
        let alertController = UIAlertController(title: "Selecciona un tema",
                                                message: nil,
                                                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Claro", style: .default, handler: { [weak self] _ in
            self?.setAppTheme(.light)
        }))

        alertController.addAction(UIAlertAction(title: "Oscuro", style: .default, handler: { [weak self] _ in
            self?.setAppTheme(.dark)
        }))

        alertController.addAction(UIAlertAction(title: "Automático", style: .default, handler: { [weak self] _ in
            self?.setAppTheme(.unspecified)
        }))

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        if let sheet = alertController.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        present(alertController, animated: true, completion: nil)
    }

    private func setAppTheme(_ style: UIUserInterfaceStyle) {
        viewModel.updateTheme(style)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = style
            }, completion: nil)
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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let loginViewController = container.makeLoginViewController()

            window.rootViewController = loginViewController
            window.makeKeyAndVisible()

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    private func navigateToRegistrarPartidos() {
        let registrarPartidosVC = container.makeRegistrarPartidosViewController()
        navigationController?.pushViewController(registrarPartidosVC, animated: true)
    }

}
