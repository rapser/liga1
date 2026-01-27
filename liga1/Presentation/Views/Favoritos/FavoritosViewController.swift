//
//  FavoritosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 24/12/24.
//  Updated on 17/01/26 - Added segmented control and teams
//

import UIKit
import Combine

class FavoritosViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel: FavoritosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Partidos", "Equipos"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .liga1Red
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.liga1Red], for: .normal)
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    // MARK: - Empty States

    private lazy var emptyMatchesView = UIView().background(.systemBackground)
    private lazy var emptyMatchesStack = createEmptyStateStack()
    private lazy var emptyMatchesIcon = createStarIcon()
    private lazy var emptyMatchesTitleLabel = UILabel()
        .text("Agrega tu primer partido")
        .font(.systemFont(ofSize: 18, weight: .bold))
        .textColor(.label)
        .alignment(.center)

    private lazy var emptyMatchesDescLabel = UILabel()
        .text("Ten todos los partidos importantes\nen un solo lugar")
        .font(.systemFont(ofSize: 14, weight: .regular))
        .textColor(.secondaryLabel)
        .alignment(.center)
        .lines(0)

    private lazy var emptyTeamsView = UIView().background(.systemBackground)
    private lazy var emptyTeamsStack = createEmptyStateStack()
    private lazy var emptyTeamsIcon = createStarIcon()
    private lazy var emptyTeamsTitleLabel = UILabel()
        .text("Agrega tu primer equipo")
        .font(.systemFont(ofSize: 18, weight: .bold))
        .textColor(.label)
        .alignment(.center)

    private lazy var emptyTeamsDescLabel = UILabel()
        .text("Ten todos los partidos y las noticias importantes\nde tus equipos favoritos en un solo lugar")
        .font(.systemFont(ofSize: 14, weight: .regular))
        .textColor(.secondaryLabel)
        .alignment(.center)
        .lines(0)

    private lazy var searchTeamButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Buscar equipo"
        config.cornerStyle = .medium
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(searchTeamTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    init(viewModel: FavoritosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favoritos"

        setupNavigationBar()
        setupSegmentedControl()
        setupTableView()
        setupEmptyStates()
        bindViewModel()
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Favoritos"
    }

    // MARK: - Setup UI

    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTeamTapped)
        )
        addButton.tintColor = .liga1Red
        navigationItem.rightBarButtonItem = addButton

        // Inicialmente oculto (solo visible en sección Equipos)
        navigationItem.rightBarButtonItem?.isHidden = true
    }

    private func createStarIcon() -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        return UIImageView()
            .image(UIImage(systemName: "star", withConfiguration: config))
            .tintColor(.systemGray3)
            .contentMode(.scaleAspectFit)
    }

    private func createEmptyStateStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }

    private func setupSegmentedControl() {
        segmentedControl
            .addTo(view)
            .pinTop(constant: Spacing.medium, useSafeArea: true)
            .pinHorizontal(padding: Spacing.standard)
            .height(32)
    }

    private func setupTableView() {
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self

        tableView
            .addTo(view)
            .pinTop(to: segmentedControl.bottomAnchor, constant: Spacing.medium)
            .pinLeading()
            .pinTrailing()
            .pinBottom()
    }

    private func setupEmptyStates() {
        // Setup Empty Matches
        emptyMatchesView
            .addTo(view)
            .pinTop(to: segmentedControl.bottomAnchor, constant: Spacing.medium)
            .pinLeading()
            .pinTrailing()
            .pinBottom()
            .hidden()

        emptyMatchesStack
            .addTo(emptyMatchesView)
            .centerInSuperview()
            .pinHorizontal(padding: Spacing.extraLarge)

        emptyMatchesIcon.square(80)

        emptyMatchesStack.addArrangedSubview(emptyMatchesIcon)
        emptyMatchesStack.addArrangedSubview(emptyMatchesTitleLabel)
        emptyMatchesStack.addArrangedSubview(emptyMatchesDescLabel)

        // Setup Empty Teams
        emptyTeamsView
            .addTo(view)
            .pinTop(to: segmentedControl.bottomAnchor, constant: Spacing.medium)
            .pinLeading()
            .pinTrailing()
            .pinBottom()
            .hidden()

        emptyTeamsStack
            .addTo(emptyTeamsView)
            .centerInSuperview()
            .pinHorizontal(padding: Spacing.extraLarge)

        emptyTeamsIcon.square(80)
        searchTeamButton.prepareForAutoLayout()

        emptyTeamsStack.addArrangedSubview(emptyTeamsIcon)
        emptyTeamsStack.addArrangedSubview(emptyTeamsTitleLabel)
        emptyTeamsStack.addArrangedSubview(emptyTeamsDescLabel)
        emptyTeamsStack.addArrangedSubview(searchTeamButton)
    }

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        let logoLocal = UIImage(named: matchUI.equipoLocalId ?? "shield.fill")
        let logoVisitante = UIImage(named: matchUI.equipoVisitanteId ?? "shield.fill")

        cell.delegate = self
        cell.configure(with: matchUI, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }

    private func configureTeamCell(at indexPath: IndexPath) -> UITableViewCell {
        let team = viewModel.teams[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as? TeamTableViewCell else {
            return UITableViewCell()
        }

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

        let containerView = UIView().background(.systemBackground)
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
        return viewModel.selectedSegment == .matches ? UITableView.automaticDimension : 60
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
        viewModel.toggleFavoriteTeam(teamId: team.nombre)
    }
}

// MARK: - TeamSearchModalDelegate

extension FavoritosViewController: TeamSearchModalDelegate {
    func didSelectTeam(_ team: TeamUI) {
        viewModel.toggleFavoriteTeam(teamId: team.nombre)
    }
}
