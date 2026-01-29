//
//  ProfileViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/10/24.
//  Refactored with AppKit on 2026-01-28
//

import UIKit
import Combine
import UserNotifications

class ProfileViewController: UIViewController {

    // MARK: - UI Components
    private let containerView = ContainerView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Properties
    let viewModel: ProfileViewModel
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()

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
        configureNavigationBar()
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Setup Methods
    private func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        title = "Configuración"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupUI() {
        // Container principal
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // TableView
        setupTableView()
    }

    private func setupTableView() {
        // Configurar tableView
        tableView.prepareForAutoLayout()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        // Agregar al container
        containerView.addSubview(tableView)

        // Constraints: llenar todo el container
        tableView.fillSuperview()
    }

    // MARK: - Data & Binding
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

    // MARK: - Actions
    func handleAction(_ action: ProfileViewModel.ProfileAction) {
        switch action {
        case .notification:
            openNotificationSettings()
        case .notificationHistory:
            navigateToNotificationHistory()
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
        case .viewLogs:
            navigateToLogs()
        case .none:
            break
        }
    }

    // MARK: - Navigation
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Cerrar Sesión",
            message: "¿Estás seguro de que deseas cerrar sesión?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })

        present(alert, animated: true)
    }

    private func navigateToLogin() {
        NotificationCenter.default.post(name: NSNotification.Name("LogoutSuccessful"), object: nil)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let loginCoordinator = self.container.makeLoginCoordinator(navigationController: UINavigationController())
                loginCoordinator.delegate = nil
                loginCoordinator.start()

                window.rootViewController = loginCoordinator.navigationController
                window.makeKeyAndVisible()

                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }

    private func navigateToRegistrarPartidos() {
        let registrarPartidosVC = container.makeRegistrarPartidosViewController()
        navigationController?.pushViewController(registrarPartidosVC, animated: true)
    }

    private func navigateToNotificationHistory() {
        let notificationHistoryVC = NotificationHistoryViewController()
        navigationController?.pushViewController(notificationHistoryVC, animated: true)
    }

    private func openNotificationSettings() {
        let viewModel = container.makeNotificationSettingsViewModel()
        let notificationSettingsVC = NotificationSettingsViewController(viewModel: viewModel)
        navigationController?.pushViewController(notificationSettingsVC, animated: true)
    }

    private func navigateToLogs() {
        let logsVC = LogsViewController()
        navigationController?.pushViewController(logsVC, animated: true)
    }
}
