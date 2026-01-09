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
        // IMPORTANTE: El jornadaId debe coincidir con un documento existente en Firestore
        // Formato del jornadaId: "{torneo}_{numero}" ejemplo: "apertura_01", "clausura_10"

        // Los partidos se registrarán en: jornadas/{jornadaId}/matches/{equipoLocalId}_{equipoVisitanteId}
        let jornadaId = "apertura_01"
        let matchesToRegister: [Match] = [
            Match(id: "com_gra", equipoLocalId: "com", equipoVisitanteId: "gra", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 2, estado: .pendiente, suspendido: false),
            Match(id: "mel_cou", equipoLocalId: "mel", equipoVisitanteId: "cou", fecha: Date(), golesEquipoLocal: 3, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false)
        ]

        viewModel.registerMultipleMatches(matches: matchesToRegister, jornadaId: jornadaId)
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

     Para registrar partidos de una jornada específica, modifica el array matchesToRegister:

     let jornadaId = "apertura_10"
     let matchesToRegister: [Match] = [
         // Jornada 10 - Apertura 2026
         Match(id: "utc_cie", equipoLocalId: "utc", equipoVisitanteId: "cie", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 2, estado: .pendiente, suspendido: false),
         Match(id: "gar_adt", equipoLocalId: "gar", equipoVisitanteId: "adt", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false),
         Match(id: "val_com", equipoLocalId: "val", equipoVisitanteId: "com", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false),
         Match(id: "cus_cou", equipoLocalId: "cus", equipoVisitanteId: "cou", fecha: Date(), golesEquipoLocal: 2, golesEquipoVisitante: 1, estado: .pendiente, suspendido: false),
         Match(id: "sba_gra", equipoLocalId: "sba", equipoVisitanteId: "gra", fecha: Date(), golesEquipoLocal: 0, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false),
         Match(id: "hua_cri", equipoLocalId: "hua", equipoVisitanteId: "cri", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 2, estado: .pendiente, suspendido: false),
         Match(id: "ali_man", equipoLocalId: "ali", equipoVisitanteId: "man", fecha: Date(), golesEquipoLocal: 1, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false),
         Match(id: "atl_uni", equipoLocalId: "atl", equipoVisitanteId: "uni", fecha: Date(), golesEquipoLocal: 0, golesEquipoVisitante: 3, estado: .pendiente, suspendido: false),
         Match(id: "mel_cha", equipoLocalId: "mel", equipoVisitanteId: "cha", fecha: Date(), golesEquipoLocal: 2, golesEquipoVisitante: 0, estado: .pendiente, suspendido: false)
     ]

     IMPORTANTE:
     - jornadaId: Debe coincidir con un documento existente en Firestore (formato: "{torneo}_{numero}")
     - Estructura en Firestore: jornadas/{jornadaId}/matches/{equipoLocalId}_{equipoVisitanteId}
     - Match ID format: "{equipoLocalId}_{equipoVisitanteId}" (ej: "utc_cie")
     - Antes de usar, asegúrate de que el documento jornada ya existe en Firestore

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
