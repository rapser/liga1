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
    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var profileHeaderView = createProfileHeaderView()

    // MARK: - Properties
    let viewModel: ProfileViewModel
    private let container: DIContainer
    private let eventBus: AppEventBusProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(viewModel: ProfileViewModel, container: DIContainer, eventBus: AppEventBusProtocol) {
        self.viewModel = viewModel
        self.container = container
        self.eventBus = eventBus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:container:eventBus:)")
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
        view.backgroundColor = .appBackground
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
        tableView.backgroundColor = .appBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        // Agregar header
        tableView.tableHeaderView = profileHeaderView

        // Agregar al container
        containerView.addSubview(tableView)

        // Constraints: llenar todo el container
        tableView.fillSuperview()
    }

    private func createProfileHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        headerView.backgroundColor = .appBackground

        // Profile Image
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.tag = 100 // Tag para encontrarlo después

        // Name Label
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.text = "Usuario"
        nameLabel.tag = 101

        // Email Label
        let emailLabel = UILabel()
        emailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .secondaryLabel
        emailLabel.text = ""
        emailLabel.tag = 102

        // Stack vertical para nombre y email
        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        // Stack horizontal para imagen y textos
        let mainStack = UIStackView(arrangedSubviews: [profileImageView, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center

        // Constraints
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            mainStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    private func updateProfileHeader() {
        guard let headerView = tableView.tableHeaderView else { return }

        // Actualizar imagen
        if let imageView = headerView.viewWithTag(100) as? UIImageView {
            if let imageData = viewModel.profileImageData,
               let image = UIImage(data: imageData) {
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
            } else {
                // Imagen por defecto
                imageView.image = UIImage(systemName: "person.circle.fill")
                imageView.tintColor = .systemGray3
                imageView.contentMode = .scaleAspectFit
            }
        }

        // Actualizar nombre
        if let nameLabel = headerView.viewWithTag(101) as? UILabel {
            nameLabel.text = viewModel.displayName
        }

        // Actualizar email
        if let emailLabel = headerView.viewWithTag(102) as? UILabel {
            emailLabel.text = viewModel.email
        }
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
                self?.eventBus.publish(.logoutRequested)
            }
            .store(in: &cancellables)

        // Bind user profile data
        viewModel.$displayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProfileHeader()
            }
            .store(in: &cancellables)

        viewModel.$email
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProfileHeader()
            }
            .store(in: &cancellables)

        viewModel.$profileImageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProfileHeader()
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

    private func openNotificationSettings() {
        let viewModel = container.makeNotificationSettingsViewModel()
        let notificationSettingsVC = NotificationSettingsViewController(viewModel: viewModel)
        navigationController?.pushViewController(notificationSettingsVC, animated: true)
    }

    private func navigateToNotificationHistory() {
        let notificationHistoryVC = container.makeNotificationHistoryViewController()
        navigationController?.pushViewController(notificationHistoryVC, animated: true)
    }
}
