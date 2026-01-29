//
//  NotificationSettingsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import UIKit
import UserNotifications
import Combine

class NotificationSettingsViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: NotificationSettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    private let containerView = ContainerView()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Permitir Notificaciones"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.prepareForAutoLayout()
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Activa las notificaciones para recibir alertas sobre partidos en vivo, resultados y más."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()
    
    private lazy var openSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Abrir Configuración", for: .normal)
        button.backgroundColor = .liga1Red
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.prepareForAutoLayout()
        button.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bell.fill")
        imageView.tintColor = .liga1Red
        imageView.contentMode = .scaleAspectFit
        imageView.prepareForAutoLayout()
        return imageView
    }()

    // NUEVO: Card para toggle de notificaciones push
    private lazy var notificationsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.prepareForAutoLayout()
        return view
    }()

    private lazy var notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Recibir notificaciones"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var notificationsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Activa para recibir notificaciones de tus equipos favoritos"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var notificationsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .liga1Red
        toggle.prepareForAutoLayout()
        toggle.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.prepareForAutoLayout()
        return view
    }()

    // MARK: - Initialization

    init(viewModel: NotificationSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Notificaciones"
        setupUI()
        bindViewModel()
        checkNotificationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationStatus()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        containerView.attachToSafeArea(in: view)
        contentView
            .addTo(containerView)
            .fillSuperview()

        // NUEVO: Card de notificaciones push
        notificationsCard
            .addTo(contentView)
            .pinTop(constant: 20)
            .pinHorizontal(padding: 16)

        // Switch dentro de la card
        notificationsSwitch
            .addTo(notificationsCard)
            .pinTop(constant: 16)
            .pinTrailing(constant: 16)

        // Label principal
        notificationsLabel
            .addTo(notificationsCard)
            .pinTop(constant: 16)
            .pinLeading(constant: 16)
            .pinTrailing(to: notificationsSwitch.leadingAnchor, constant: 12)

        // Label descriptivo
        notificationsDescriptionLabel
            .addTo(notificationsCard)
            .pinTop(to: notificationsLabel.bottomAnchor, constant: 4)
            .pinLeading(constant: 16)
            .pinTrailing(to: notificationsSwitch.leadingAnchor, constant: 12)
            .pinBottom(constant: 16)

        // Separator
        separatorView
            .addTo(contentView)
            .pinTop(to: notificationsCard.bottomAnchor, constant: 24)
            .pinHorizontal(padding: 16)
            .height(1)

        // Icon
        iconImageView
            .addTo(contentView)
            .centerX()
            .pinTop(to: separatorView.bottomAnchor, constant: 40)
            .square(80)

        // Title
        titleLabel
            .addTo(contentView)
            .pinTop(to: iconImageView.bottomAnchor, constant: 24)
            .pinHorizontal(padding: 24)

        // Description
        descriptionLabel
            .addTo(contentView)
            .pinTop(to: titleLabel.bottomAnchor, constant: 16)
            .pinHorizontal(padding: 24)

        // Status
        statusLabel
            .addTo(contentView)
            .pinTop(to: descriptionLabel.bottomAnchor, constant: 24)
            .pinHorizontal(padding: 24)

        // Button
        openSettingsButton
            .addTo(contentView)
            .pinTop(to: statusLabel.bottomAnchor, constant: 32)
            .pinHorizontal(padding: 24)
            .height(50)
            .pinBottom(constant: 40)
    }
    
    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$pushNotificationsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.notificationsSwitch.isOn = enabled
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func notificationsSwitchChanged() {
        let enabled = notificationsSwitch.isOn
        viewModel.updatePushNotificationsEnabled(enabled)
    }

    @objc private func openSettingsTapped() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            showError(title: "Error", message: "No se pudo abrir la configuración del sistema")
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { [weak self] success in
                if !success {
                    self?.showError(title: "Error", message: "No se pudo abrir la configuración del sistema")
                }
            }
        } else {
            showError(title: "Error", message: "No se puede abrir la configuración del sistema")
        }
    }
    
    // MARK: - Helpers
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.updateUI(with: settings)
            }
        }
    }
    
    private func updateUI(with settings: UNNotificationSettings) {
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            statusLabel.text = "✅ Notificaciones activadas"
            statusLabel.textColor = .systemGreen
            iconImageView.tintColor = .systemGreen
            openSettingsButton.setTitle("Abrir Configuración", for: .normal)
        case .denied:
            statusLabel.text = "❌ Notificaciones desactivadas\nToca el botón para activarlas en Configuración"
            statusLabel.textColor = .systemRed
            iconImageView.tintColor = .systemRed
            openSettingsButton.setTitle("Abrir Configuración", for: .normal)
        case .notDetermined:
            statusLabel.text = "⚠️ Permisos de notificaciones no solicitados"
            statusLabel.textColor = .systemOrange
            iconImageView.tintColor = .systemOrange
            openSettingsButton.setTitle("Solicitar Permisos", for: .normal)
            openSettingsButton.removeTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
            openSettingsButton.addTarget(self, action: #selector(requestPermissionsTapped), for: .touchUpInside)
        @unknown default:
            statusLabel.text = "Estado desconocido"
            statusLabel.textColor = .secondaryLabel
        }
    }
    
    @objc private func requestPermissionsTapped() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.checkNotificationStatus()
                } else if let error = error {
                    self?.showError(title: "Error", message: error.localizedDescription)
                } else {
                    self?.checkNotificationStatus()
                }
            }
        }
    }
}
