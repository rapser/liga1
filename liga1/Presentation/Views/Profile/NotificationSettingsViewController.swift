//
//  NotificationSettingsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.prepareForAutoLayout()
        return scrollView
    }()
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Notificaciones"
        setupUI()
        checkNotificationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationStatus()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Scroll View
        scrollView
            .addTo(view)
            .fillSuperview()
        
        // Content View
        contentView.addTo(scrollView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Icon
        iconImageView
            .addTo(contentView)
            .centerX()
            .pinTop(constant: 60)
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
    
    // MARK: - Actions
    
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
