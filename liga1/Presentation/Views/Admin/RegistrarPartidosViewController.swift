//
//  RegistrarPartidosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//  Refactored by Claude Code on 03/01/26.
//

import UIKit
import Combine

/// Vista administrativa para registrar masivamente partidos de la Liga 1
class RegistrarPartidosViewController: UIViewController {

    // MARK: - Properties

    let viewModel: RegistrarPartidosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.prepareForAutoLayout()
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.prepareForAutoLayout()
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registro Masivo de Partidos"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Herramienta administrativa para registrar partidos de la Liga 1"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.prepareForAutoLayout()
        return label
    }()

    private lazy var registrarPartidosButton: UIButton = {
        let button = LayoutPresets.primaryButton(
            title: "Registrar Partidos de Ejemplo",
            backgroundColor: .systemBlue
        )
        button.addTarget(self, action: #selector(registrarPartidosTapped), for: .touchUpInside)
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.prepareForAutoLayout()
        return indicator
    }()

    // MARK: - Initialization

    init(viewModel: RegistrarPartidosViewModel = DIContainer.shared.makeRegistrarPartidosViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = DIContainer.shared.makeRegistrarPartidosViewModel()
        super.init(coder: coder)
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
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupConstraints() {
        scrollView.addTo(view)
            .pinTop(useSafeArea: true)
            .pinBottom(useSafeArea: true)
            .pinHorizontal()

        contentStackView.addTo(scrollView)
            .pinEdges()
            .width(to: view)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(registrarPartidosButton)

        contentStackView.setCustomSpacing(40, after: descriptionLabel)

        activityIndicator.addTo(view)
            .centerInSuperview()

        registrarPartidosButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.registrarPartidosButton.isEnabled = false
                    self?.registrarPartidosButton.alpha = 0.5
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.registrarPartidosButton.isEnabled = true
                    self?.registrarPartidosButton.alpha = 1.0
                }
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
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

    @objc private func registrarPartidosTapped() {
        let confirmAlert = UIAlertController(
            title: "Confirmar Registro",
            message: "¿Estás seguro de que deseas registrar estos partidos?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Registrar", style: .default) { [weak self] _ in
            self?.registerExampleMatches()
        })

        present(confirmAlert, animated: true)
    }

    // MARK: - Private Methods

    private func registerExampleMatches() {
        // Ejemplo de partidos para registrar rápidamente en 2026
        // Este array puede ser modificado según la jornada que se necesite registrar
        let partidosARegistrar: [Partido] = [
            Partido(teamAId: "com", teamBId: "gra", fecha: "03", jornadaId: "clausura_2026_01", torneo: "clausura", golesTeamA: 1, golesTeamB: 2),
            Partido(teamAId: "mel", teamBId: "cou", fecha: "06", jornadaId: "clausura_2026_01", torneo: "clausura", golesTeamA: 3, golesTeamB: 0)
        ]

        viewModel.registerMultipleMatches(partidos: partidosARegistrar)
    }

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

    /*
     EJEMPLO DE USO PARA 2026:

     Para registrar partidos de una jornada específica, modifica el array partidosARegistrar:

     let partidosARegistrar: [Partido] = [
         // Jornada 10 - Ejemplo
         Partido(teamAId: "utc", teamBId: "cie", fecha: "10", golesTeamA: 1, golesTeamB: 2),
         Partido(teamAId: "gar", teamBId: "adt", fecha: "10", golesTeamA: 1, golesTeamB: 0),
         Partido(teamAId: "val", teamBId: "com", fecha: "10", golesTeamA: 1, golesTeamB: 0),
         Partido(teamAId: "cus", teamBId: "cou", fecha: "10", golesTeamA: 2, golesTeamB: 1),
         Partido(teamAId: "sba", teamBId: "gra", fecha: "10", golesTeamA: 0, golesTeamB: 0),
         Partido(teamAId: "hua", teamBId: "cri", fecha: "10", golesTeamA: 1, golesTeamB: 2),
         Partido(teamAId: "ali", teamBId: "man", fecha: "10", golesTeamA: 1, golesTeamB: 0),
         Partido(teamAId: "atl", teamBId: "uni", fecha: "10", golesTeamA: 0, golesTeamB: 3),
         Partido(teamAId: "mel", teamBId: "cha", fecha: "10", golesTeamA: 2, golesTeamB: 0)
     ]

     Códigos de equipos:
     - ali: Alianza Lima
     - uni: Universitario
     - cri: Sporting Cristal
     - cie: Cienciano
     - cus: Cusco FC
     - adt: ADT
     - atl: Alianza Atlético
     - mel: Melgar
     - gra: Atlético Grau
     - gar: Deportivo Garcilaso
     - sba: Sport Boys
     - cha: Chankas CYC
     - utc: UTC Cajamarca
     - hua: Sport Huancayo
     - com: Unión Comercio
     - man: Carlos Mannucci
     - val: César Vallejo
     - cou: Comerciantes Unidos
     */
}
