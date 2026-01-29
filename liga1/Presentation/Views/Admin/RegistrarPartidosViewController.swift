//
//  RegistrarPartidosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//  Refactored by miguel tomairo on 03/01/26.
//

import UIKit
import Combine

/// Vista administrativa para registrar masivamente partidos de la Liga 1
class RegistrarPartidosViewController: UIViewController {

    // MARK: - Properties

    let viewModel: RegistrarPartidosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let containerView = ContainerView()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.large
        stackView.prepareForAutoLayout()
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registro Masivo de Partidos"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Herramienta administrativa para registrar todas las jornadas del Torneo Apertura 2026"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Se registrarán 17 jornadas con 9 partidos cada una.\nTodos los partidos tendrán estado 'pendiente' y 0 goles por defecto.\nFecha base: 30 de enero 2026"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var registrarTodoButton: UIButton = {
        let button = LayoutPresets.primaryButton(
            title: "Registrar Todas las Jornadas",
            backgroundColor: .liga1Red,
            cornerRadius: 12,
            height: 56
        )
        button.addTarget(self, action: #selector(registrarTodoTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .liga1Red
        indicator.prepareForAutoLayout()
        return indicator
    }()

    // MARK: - Initialization

    init(viewModel: RegistrarPartidosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Registrar Partidos"
        view.backgroundColor = .appBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupConstraints() {
        containerView.attachToSafeArea(in: view)

        contentStackView
            .addTo(containerView)
            .pinTop(constant: Spacing.extraLarge, useSafeArea: false)
            .pinLeading(constant: Spacing.standard)
            .pinTrailing(constant: Spacing.standard)
            .pinBottom(constant: Spacing.extraLarge, useSafeArea: false)

        activityIndicator
            .addTo(view)
            .centerInSuperview()

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(infoLabel)
        
        // Espaciado antes del botón
        contentStackView.setCustomSpacing(Spacing.extraLarge * 2, after: infoLabel)
        
        contentStackView.addArrangedSubview(registrarTodoButton)
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.registrarTodoButton.isEnabled = false
                    self?.registrarTodoButton.alpha = 0.6
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.registrarTodoButton.isEnabled = true
                    self?.registrarTodoButton.alpha = 1.0
                }
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(
                    title: "Error",
                    message: error.localizedDescription,
                    buttonTitle: "OK"
                ) { [weak self] _ in
                    self?.viewModel.clearError()
                }
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showSuccess(message)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func registrarTodoTapped() {
        let confirmAlert = UIAlertController(
            title: "Confirmar Registro",
            message: "¿Estás seguro de que deseas registrar las 17 jornadas del Torneo Apertura?\n\nSe crearán 17 documentos de jornadas y 153 partidos en total.",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Registrar", style: .default) { [weak self] _ in
            self?.viewModel.registerAllAperturaJornadas()
        })

        present(confirmAlert, animated: true)
    }

    // MARK: - Private Methods

    private func showSuccess(_ message: String) {
        let alert = UIAlertController(
            title: "Éxito",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        viewModel.clearSuccessMessage()
    }

}
