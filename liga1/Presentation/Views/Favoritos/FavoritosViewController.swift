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
        control.selectedSegmentTintColor = .liga1Red
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.liga1Red], for: .normal)
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    // MARK: - Empty States

    // Empty State for Matches
    private lazy var emptyMatchesView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var emptyMatchesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private lazy var emptyMatchesIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        imageView.image = UIImage(systemName: "star", withConfiguration: config)
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var emptyMatchesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Agrega tu primer partido"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var emptyMatchesDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ten todos los partidos importantes\nen un solo lugar"
        label.font = .systemFont(ofSize: 14, weight: .regular)
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

    private lazy var emptyTeamsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private lazy var emptyTeamsIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        imageView.image = UIImage(systemName: "star", withConfiguration: config)
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var emptyTeamsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Agrega tu primer equipo"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var emptyTeamsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ten todos los partidos y las noticias importantes\nde tus equipos favoritos en un solo lugar"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

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
        // Setup Empty Matches View
        view.addSubview(emptyMatchesView)
        emptyMatchesView.addSubview(emptyMatchesStackView)

        emptyMatchesStackView.addArrangedSubview(emptyMatchesIconView)
        emptyMatchesStackView.addArrangedSubview(emptyMatchesTitleLabel)
        emptyMatchesStackView.addArrangedSubview(emptyMatchesDescriptionLabel)

        emptyMatchesView.translatesAutoresizingMaskIntoConstraints = false
        emptyMatchesStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyMatchesIconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyMatchesView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            emptyMatchesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyMatchesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyMatchesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyMatchesStackView.centerXAnchor.constraint(equalTo: emptyMatchesView.centerXAnchor),
            emptyMatchesStackView.centerYAnchor.constraint(equalTo: emptyMatchesView.centerYAnchor),
            emptyMatchesStackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyMatchesView.leadingAnchor, constant: 32),
            emptyMatchesStackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyMatchesView.trailingAnchor, constant: -32),

            emptyMatchesIconView.widthAnchor.constraint(equalToConstant: 80),
            emptyMatchesIconView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Setup Empty Teams View
        view.addSubview(emptyTeamsView)
        emptyTeamsView.addSubview(emptyTeamsStackView)

        emptyTeamsStackView.addArrangedSubview(emptyTeamsIconView)
        emptyTeamsStackView.addArrangedSubview(emptyTeamsTitleLabel)
        emptyTeamsStackView.addArrangedSubview(emptyTeamsDescriptionLabel)
        emptyTeamsStackView.addArrangedSubview(searchTeamButton)

        emptyTeamsView.translatesAutoresizingMaskIntoConstraints = false
        emptyTeamsStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyTeamsIconView.translatesAutoresizingMaskIntoConstraints = false
        searchTeamButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyTeamsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            emptyTeamsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyTeamsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyTeamsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyTeamsStackView.centerXAnchor.constraint(equalTo: emptyTeamsView.centerXAnchor),
            emptyTeamsStackView.centerYAnchor.constraint(equalTo: emptyTeamsView.centerYAnchor),
            emptyTeamsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyTeamsView.leadingAnchor, constant: 32),
            emptyTeamsStackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyTeamsView.trailingAnchor, constant: -32),

            emptyTeamsIconView.widthAnchor.constraint(equalToConstant: 80),
            emptyTeamsIconView.heightAnchor.constraint(equalToConstant: 80)
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
