//
//  FavoritosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 24/12/24.
//  Updated on 17/01/26 - Added segmented control and teams
//  Refactored with AppKit on 2026-01-28
//

import UIKit
import Combine

class FavoritosViewController: UIViewController {

    // MARK: - UI Components
    private let containerView = ContainerView()
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Partidos", "Equipos"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .liga1Red
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.liga1Red], for: .normal)
        return control
    }()
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Properties
    let viewModel: FavoritosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Empty States
    private let emptyMatchesView = EmptyStateView()
    private let emptyTeamsView = EmptyStateView()
    private let searchTeamButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Buscar equipo"
        config.cornerStyle = .medium
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        return UIButton(configuration: config)
    }()

    // MARK: - Initialization

    init(viewModel: FavoritosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        bindViewModel()
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFavoriteTeamsIfNeeded()
    }

    // MARK: - Setup Methods
    private func configureNavigationBar() {
        view.backgroundColor = .appBackground
        title = "Favoritos"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTeamTapped)
        )
        addButton.tintColor = .liga1Red
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.isHidden = true // Inicialmente oculto
    }

    private func setupUI() {
        // Container principal
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // Segmented Control
        setupSegmentedControl()

        // TableView
        setupTableView()

        // Empty States
        setupEmptyStates()
    }

    private func setupSegmentedControl() {
        segmentedControl.prepareForAutoLayout()
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        containerView.addSubview(segmentedControl)

        segmentedControl.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(
                top: Spacing.medium,
                left: Spacing.standard,
                bottom: 0,
                right: Spacing.standard
            )
        )
        segmentedControl.height(32)
    }

    private func setupTableView() {
        tableView.prepareForAutoLayout()
        tableView.registerCell(MatchTableViewCell.self)
        tableView.registerCell(TeamTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        containerView.addSubview(tableView)

        tableView.anchor(
            top: segmentedControl.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: Spacing.medium, left: 0, bottom: 0, right: 0)
        )
    }

    private func setupEmptyStates() {
        // Configure empty matches
        emptyMatchesView.configure(
            systemImage: "star",
            title: "Agrega tu primer partido",
            message: "Ten todos los partidos importantes\nen un solo lugar"
        )
        emptyMatchesView.prepareForAutoLayout()
        emptyMatchesView.isHidden = true

        containerView.addSubview(emptyMatchesView)

        emptyMatchesView.anchor(
            top: segmentedControl.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: Spacing.medium, left: 0, bottom: 0, right: 0)
        )

        // Configure empty teams with button
        emptyTeamsView.configure(
            systemImage: "star",
            title: "Agrega tu primer equipo",
            message: "Ten todos los partidos y las noticias importantes\nde tus equipos favoritos en un solo lugar"
        )
        emptyTeamsView.prepareForAutoLayout()
        emptyTeamsView.isHidden = true

        // Add search button to empty teams view
        searchTeamButton.prepareForAutoLayout()
        searchTeamButton.addTarget(self, action: #selector(searchTeamTapped), for: .touchUpInside)
        emptyTeamsView.addCustomView(searchTeamButton)

        containerView.addSubview(emptyTeamsView)

        emptyTeamsView.anchor(
            top: segmentedControl.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: Spacing.medium, left: 0, bottom: 0, right: 0)
        )
    }

    // MARK: - Data & Binding
    private func bindViewModel() {
        viewModel.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)

        viewModel.$teams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)

        viewModel.$favoriteTeamIds
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

    private func updateView() {
        tableView.reloadData()

        let isMatchesSegment = viewModel.selectedSegment == .matches
        let hasMatches = !viewModel.matches.isEmpty
        let hasTeams = !viewModel.teams.isEmpty

        // Mostrar botón "+" solo en la sección de Equipos
        navigationItem.rightBarButtonItem?.isHidden = isMatchesSegment

        if isMatchesSegment {
            emptyMatchesView.isHidden = hasMatches
            emptyTeamsView.isHidden = true
            tableView.isHidden = !hasMatches
        } else {
            emptyMatchesView.isHidden = true
            emptyTeamsView.isHidden = hasTeams
            tableView.isHidden = !hasTeams
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        viewModel.selectedSegment = FavoritesSegment(rawValue: segmentedControl.selectedSegmentIndex) ?? .matches
        updateView()
    }

    @objc private func addTeamTapped() {
        searchTeamTapped()
    }

    @objc private func searchTeamTapped() {
        let modal = TeamSearchModalViewController()
        modal.configure(teams: viewModel.allTeams, favoriteTeamIds: viewModel.favoriteTeamIds)
        modal.delegate = self
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve
        present(modal, animated: true)

        viewModel.$favoriteTeamIds
            .receive(on: DispatchQueue.main)
            .sink { [weak modal] favoriteTeamIds in
                modal?.updateFavorites(favoriteTeamIds)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension FavoritosViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.selectedSegment == .matches ? viewModel.matches.count : viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.selectedSegment == .matches {
            return configureMatchCell(at: indexPath)
        } else {
            return configureTeamCell(at: indexPath)
        }
    }

    private func configureMatchCell(at indexPath: IndexPath) -> UITableViewCell {
        let matchUI = viewModel.matches[indexPath.row]
        let cell = tableView.dequeueReusableCell(MatchTableViewCell.self, for: indexPath)

        let logoLocal = UIImage(named: matchUI.equipoLocalId ?? "shield.fill")
        let logoVisitante = UIImage(named: matchUI.equipoVisitanteId ?? "shield.fill")

        cell.delegate = self
        cell.configure(with: matchUI, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }

    private func configureTeamCell(at indexPath: IndexPath) -> UITableViewCell {
        let team = viewModel.teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(TeamTableViewCell.self, for: indexPath)

        let logo = UIImage(named: team.logo)
        cell.delegate = self
        cell.configure(with: team, logo: logo)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard (viewModel.selectedSegment == .matches && !viewModel.matches.isEmpty) ||
              (viewModel.selectedSegment == .teams && !viewModel.teams.isEmpty) else {
            return nil
        }

        let containerView = UIView().background(.appBackground)
        let titleText = viewModel.selectedSegment == .matches ? "Mis Partidos Favoritos" : "Mis Equipos Favoritos"

        LayoutPresets.titleLabel(text: titleText, fontSize: 18)
            .addTo(containerView)
            .pinLeading(constant: Spacing.standard)
            .pinTop(constant: Spacing.small)
            .pinBottom(constant: Spacing.small)

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let hasContent = viewModel.selectedSegment == .matches ? !viewModel.matches.isEmpty : !viewModel.teams.isEmpty
        return hasContent ? 50 : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - MatchTableViewCellDelegate

extension FavoritosViewController: MatchTableViewCellDelegate {
    func didTapFavorite(cell: MatchTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let matchUI = viewModel.matches[indexPath.row]
        viewModel.toggleFavorite(matchId: matchUI.id)
    }
}

// MARK: - TeamTableViewCellDelegate

extension FavoritosViewController: TeamTableViewCellDelegate {
    func didTapFavorite(cell: TeamTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let team = viewModel.teams[indexPath.row]
        // IMPORTANTE: Usar logo (código corto) en lugar de nombre para los topics
        // Normalizar a minúsculas para asegurar consistencia con el backend
        let teamCode = team.logo.lowercased()
        viewModel.toggleFavoriteTeam(teamId: teamCode)
    }
}

// MARK: - TeamSearchModalDelegate

extension FavoritosViewController: TeamSearchModalDelegate {
    func didSelectTeam(_ team: TeamUI) {
        // IMPORTANTE: Usar logo (código corto) en lugar de nombre para los topics
        // Normalizar a minúsculas para asegurar consistencia con el backend
        let teamCode = team.logo.lowercased()
        viewModel.toggleFavoriteTeam(teamId: teamCode)
    }
}
