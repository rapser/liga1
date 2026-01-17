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
        let items = ["Partidos", "Equipos"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    // Empty State for Matches
    private lazy var emptyMatchesView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var emptyMatchesLabel: UILabel = {
        let label = UILabel()
        label.text = "Agrega tu primer partido\nTen todos los partidos importantes en un solo lugar"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // Empty State for Teams
    private lazy var emptyTeamsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var emptyTeamsLabel: UILabel = {
        let label = UILabel()
        label.text = "Agrega tu primer equipo\nTen todos los partidos y las noticias importantes de tus equipos favoritos en un solo lugar"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var searchTeamButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Buscar equipo"
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white

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

        setupSegmentedControl()
        setupTableView()
        setupEmptyStates()
        bindViewModel()
        updateView()
    }

    // MARK: - Setup UI

    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupTableView() {
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyStates() {
        // Empty Matches View
        view.addSubview(emptyMatchesView)
        emptyMatchesView.addSubview(emptyMatchesLabel)

        emptyMatchesView.translatesAutoresizingMaskIntoConstraints = false
        emptyMatchesLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyMatchesView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            emptyMatchesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyMatchesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyMatchesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyMatchesLabel.centerXAnchor.constraint(equalTo: emptyMatchesView.centerXAnchor),
            emptyMatchesLabel.centerYAnchor.constraint(equalTo: emptyMatchesView.centerYAnchor),
            emptyMatchesLabel.leadingAnchor.constraint(equalTo: emptyMatchesView.leadingAnchor, constant: 32),
            emptyMatchesLabel.trailingAnchor.constraint(equalTo: emptyMatchesView.trailingAnchor, constant: -32)
        ])

        // Empty Teams View
        view.addSubview(emptyTeamsView)
        emptyTeamsView.addSubview(emptyTeamsLabel)
        emptyTeamsView.addSubview(searchTeamButton)

        emptyTeamsView.translatesAutoresizingMaskIntoConstraints = false
        emptyTeamsLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTeamButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyTeamsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            emptyTeamsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyTeamsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyTeamsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyTeamsLabel.centerXAnchor.constraint(equalTo: emptyTeamsView.centerXAnchor),
            emptyTeamsLabel.centerYAnchor.constraint(equalTo: emptyTeamsView.centerYAnchor, constant: -30),
            emptyTeamsLabel.leadingAnchor.constraint(equalTo: emptyTeamsView.leadingAnchor, constant: 32),
            emptyTeamsLabel.trailingAnchor.constraint(equalTo: emptyTeamsView.trailingAnchor, constant: -32),

            searchTeamButton.topAnchor.constraint(equalTo: emptyTeamsLabel.bottomAnchor, constant: 24),
            searchTeamButton.centerXAnchor.constraint(equalTo: emptyTeamsView.centerXAnchor),
            searchTeamButton.widthAnchor.constraint(equalToConstant: 160),
            searchTeamButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        emptyMatchesView.isHidden = true
        emptyTeamsView.isHidden = true
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

    @objc private func searchTeamTapped() {
        let modal = TeamSearchModalViewController()
        modal.configure(teams: viewModel.allTeams, favoriteTeamIds: viewModel.favoriteTeamIds)
        modal.delegate = self
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve
        present(modal, animated: true)

        // Observe changes in favorite teams to update modal
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

        let containerView = UIView()
        containerView.backgroundColor = .systemBackground

        let titleText = viewModel.selectedSegment == .matches ? "Mis Partidos Favoritos" : "Mis Equipos Favoritos"
        let titleLabel = LayoutPresets.titleLabel(text: titleText, fontSize: 18)
        titleLabel
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
