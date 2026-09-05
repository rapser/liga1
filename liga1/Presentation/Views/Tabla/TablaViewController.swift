//
//  TablaViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//  Refactored with AppKit on 2026-01-28
//

import UIKit
import Combine

class TablaViewController: UIViewController {

    // MARK: - UI Components
    private let containerView = ContainerView()
    private let tournamentSelector = UISegmentedControl(items: [TorneoType.apertura.displayName])
    private let tableView = UITableView()

    // MARK: - Properties
    let viewModel: TorneoViewModel
    private var cancellables = Set<AnyCancellable>()
    private var hasStarted = false

    /// Abre el simulador para el torneo indicado. Lo inyecta `MainTabBarController`.
    var onSimulate: ((TorneoType) -> Void)?

    // MARK: - Initialization
    init(viewModel: TorneoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScoreUpdate), name: .scoreUpdateReceived, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasStarted {
            viewModel.refreshTournamentAvailability()
            viewModel.reloadTeams(for: viewModel.selectedTorneo)
        } else {
            hasStarted = true
            viewModel.start()
        }
    }

    // MARK: - Actions
    @objc private func appWillEnterForeground() {
        viewModel.refreshTournamentAvailability()
        viewModel.reloadTeams(for: viewModel.selectedTorneo)
    }

    @objc private func handleScoreUpdate() {
        viewModel.reloadTeams(for: viewModel.selectedTorneo)
    }

    @objc private func tournamentChanged() {
        let index = tournamentSelector.selectedSegmentIndex
        guard viewModel.availableTorneos.indices.contains(index) else { return }
        viewModel.loadTeams(for: viewModel.availableTorneos[index])
    }

    // MARK: - Setup Methods
    private func configureNavigationBar() {
        view.backgroundColor = .appBackground
        title = "Tabla"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                self.onSimulate?(self.viewModel.selectedTorneo)
            }
        )
    }

    private func setupUI() {
        // Container principal
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        setupTournamentSelector()

        // TableView
        setupTableView()
    }

    private func setupTournamentSelector() {
        tournamentSelector.selectedSegmentIndex = 0
        tournamentSelector.selectedSegmentTintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        tournamentSelector.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        tournamentSelector.addTarget(self, action: #selector(tournamentChanged), for: .valueChanged)
        tournamentSelector.prepareForAutoLayout()

        containerView.addSubview(tournamentSelector)
        tournamentSelector.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(
                top: Spacing.standard,
                left: Spacing.standard,
                bottom: 0,
                right: Spacing.standard
            )
        )
        tournamentSelector.height(32)
    }

    private func setupTableView() {
        // Configurar tableView
        tableView.prepareForAutoLayout()
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 0
        tableView.tableFooterView = makeLegendFooter(for: .apertura)

        // Agregar al container
        containerView.addSubview(tableView)

        // Constraints: debajo del selector, pegado a los bordes
        tableView.anchor(
            top: tournamentSelector.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(
                top: Spacing.tiny,
                left: 0,
                bottom: 0,
                right: 0
            )
        )
    }

    private func makeLegendFooter(for torneo: TorneoType) -> UIView {
        let footer = UIView()
        footer.backgroundColor = .clear

        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.cornerCurve = .continuous
        card.prepareForAutoLayout()

        let descriptions: [(UIColor, String, String)]
        if torneo == .acumulado {
            descriptions = [
                (.libertadoresGold, "1.º–2.º", "Libertadores · Fase de grupos"),
                (.libertadoresLightGold, "3.º", "Libertadores · Fase 2"),
                (.libertadoresLighterGold, "4.º", "Libertadores · Fase 1"),
                (.sudamericanaBlue, "5.º–8.º", "Copa Sudamericana"),
                (.relegationRed, "17.º–18.º", "Descenso")
            ]
        } else {
            descriptions = [
                (.libertadoresGold, "1.º", "Campeón del Torneo \(torneo.displayName)")
            ]
        }

        let titleLabel = UILabel()
        titleLabel.text = "Leyenda"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label

        let rows = descriptions.map {
            makeLegendRow(color: $0.0, position: $0.1, text: $0.2)
        }
        let stack = UIStackView(arrangedSubviews: [titleLabel] + rows)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 7
        stack.setCustomSpacing(10, after: titleLabel)
        stack.prepareForAutoLayout()

        footer.addSubview(card)
        card.addSubview(stack)

        card.anchor(
            top: footer.topAnchor,
            leading: footer.leadingAnchor,
            bottom: footer.bottomAnchor,
            trailing: footer.trailingAnchor,
            padding: UIEdgeInsets(top: 10, left: Spacing.standard, bottom: 10, right: Spacing.standard)
        )

        stack.anchor(
            top: card.topAnchor,
            leading: card.leadingAnchor,
            bottom: card.bottomAnchor,
            trailing: card.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        )

        let height: CGFloat = torneo == .acumulado ? 174 : 86
        footer.frame = CGRect(x: 0, y: 0, width: 0, height: height)
        return footer
    }

    private func makeLegendRow(color: UIColor, position: String, text: String) -> UIView {
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 3
        colorView.prepareForAutoLayout()
        colorView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 12).isActive = true

        let positionLabel = UILabel()
        positionLabel.text = position
        positionLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        positionLabel.textColor = .label
        positionLabel.widthAnchor.constraint(equalToConstant: 58).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [colorView, positionLabel, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    // MARK: - Data & Binding
    private func configureTournamentSelector(with torneos: [TorneoType]) {
        tournamentSelector.removeAllSegments()
        for (index, torneo) in torneos.enumerated() {
            tournamentSelector.insertSegment(withTitle: torneo.displayName, at: index, animated: false)
        }
        tournamentSelector.selectedSegmentIndex = torneos.firstIndex(of: viewModel.selectedTorneo) ?? 0
    }

    private func bindViewModel() {
        viewModel.$availableTorneos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] torneos in
                self?.configureTournamentSelector(with: torneos)
            }
            .store(in: &cancellables)

        viewModel.$selectedTorneo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] torneo in
                guard let self = self else { return }
                self.tournamentSelector.selectedSegmentIndex = self.viewModel.availableTorneos.firstIndex(of: torneo) ?? 0
                self.tableView.tableFooterView = self.makeLegendFooter(for: torneo)
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$displayedTeams
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
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
