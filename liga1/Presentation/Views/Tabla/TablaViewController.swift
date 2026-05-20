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
    private let aperturaLabelView = UIView()
    private let aperturaLabel = UILabel()
    private let tableView = UITableView()

    // MARK: - Properties
    let viewModel: TorneoViewModel
    private var cancellables = Set<AnyCancellable>()

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
        loadInitialData()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScoreUpdate), name: .scoreUpdateReceived, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadTeams(for: .apertura)
    }

    // MARK: - Actions
    @objc private func appWillEnterForeground() {
        viewModel.reloadTeams(for: .apertura)
    }

    @objc private func handleScoreUpdate() {
        viewModel.reloadTeams(for: viewModel.selectedTorneo)
    }

    // MARK: - Setup Methods
    private func configureNavigationBar() {
        view.backgroundColor = .appBackground
        title = "Tabla"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupUI() {
        // Container principal
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // Label "Apertura" (view rojo)
        setupAperturaLabel()

        // TableView
        setupTableView()
    }

    private func setupAperturaLabel() {
        // Configurar el view rojo
        aperturaLabelView.backgroundColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        aperturaLabelView.layer.cornerRadius = 5.0
        aperturaLabelView.prepareForAutoLayout()

        // Configurar el label
        aperturaLabel.text = "Apertura"
        aperturaLabel.textColor = .white
        aperturaLabel.font = .systemFont(ofSize: 14, weight: .bold)
        aperturaLabel.textAlignment = .center
        aperturaLabel.prepareForAutoLayout()

        // Agregar al container
        containerView.addSubview(aperturaLabelView)
        aperturaLabelView.addSubview(aperturaLabel)

        // Constraints del view rojo
        aperturaLabelView.anchor(
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
        aperturaLabelView.height(30)

        // Constraints del label dentro del view
        aperturaLabel.centerInSuperview()
    }

    private func setupTableView() {
        // Configurar tableView
        tableView.prepareForAutoLayout()
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = makeLegendFooter()

        // Agregar al container
        containerView.addSubview(tableView)

        // Constraints: debajo del aperturaLabelView, pegado a los bordes
        tableView.anchor(
            top: aperturaLabelView.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(
                top: Spacing.small,
                left: 0,
                bottom: 0,
                right: 0
            )
        )
    }

    private func makeLegendFooter() -> UIView {
        let footer = UIView()
        footer.backgroundColor = .clear

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.prepareForAutoLayout()

        let badgeView = UIView()
        badgeView.backgroundColor = .libertadoresGold
        badgeView.layer.cornerRadius = 5
        badgeView.prepareForAutoLayout()

        let badgeLabel = UILabel()
        badgeLabel.text = "1"
        badgeLabel.font = .boldSystemFont(ofSize: 11)
        badgeLabel.textColor = .black
        badgeLabel.textAlignment = .center
        badgeLabel.prepareForAutoLayout()

        let descLabel = UILabel()
        descLabel.text = "Campeón del Torneo Apertura"
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        descLabel.prepareForAutoLayout()

        let row = UIStackView(arrangedSubviews: [badgeView, descLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.prepareForAutoLayout()

        badgeView.addSubview(badgeLabel)
        badgeLabel.centerInSuperview()
        badgeView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        badgeView.heightAnchor.constraint(equalToConstant: 22).isActive = true

        footer.addSubview(separator)
        footer.addSubview(row)

        separator.anchor(
            top: footer.topAnchor,
            leading: footer.leadingAnchor,
            trailing: footer.trailingAnchor
        )
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        row.anchor(
            top: separator.bottomAnchor,
            leading: footer.leadingAnchor,
            bottom: footer.bottomAnchor,
            padding: UIEdgeInsets(top: 10, left: Spacing.standard, bottom: 10, right: Spacing.standard)
        )

        footer.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        return footer
    }

    // MARK: - Data & Binding
    private func loadInitialData() {
        viewModel.loadTeams(for: .apertura)
    }

    private func bindViewModel() {
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
