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
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let skeletonView = FavoritosSkeletonView()

    // MARK: - Properties
    let viewModel: FavoritosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Empty States
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
        // El skeleton arranca de inmediato (isLoading = true desde el VM); bindViewModel lo detendrá.
        skeletonView.startAnimating()
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFavoriteTeamsIfNeeded()
    }

    // MARK: - Actions
    @objc private func appWillEnterForeground() {
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
    }

    private func setupUI() {
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        setupTableView()
        setupEmptyStates()
        setupSkeleton()
    }

    private func setupTableView() {
        tableView.prepareForAutoLayout()
        tableView.registerCell(TeamTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true

        containerView.addSubview(tableView)
        tableView.fillSuperview()
    }

    private func setupSkeleton() {
        skeletonView.prepareForAutoLayout()
        containerView.addSubview(skeletonView)
        skeletonView.fillSuperview()
    }

    private func setupEmptyStates() {
        emptyTeamsView.configure(
            systemImage: "star",
            title: "Agrega tu primer equipo",
            message: "Ten todos los partidos y las noticias importantes\nde tus equipos favoritos en un solo lugar"
        )
        emptyTeamsView.prepareForAutoLayout()
        emptyTeamsView.isHidden = true

        searchTeamButton.prepareForAutoLayout()
        searchTeamButton.addTarget(self, action: #selector(searchTeamTapped), for: .touchUpInside)
        emptyTeamsView.addCustomView(searchTeamButton)

        containerView.addSubview(emptyTeamsView)
        emptyTeamsView.fillSuperview()
    }

    // MARK: - Data & Binding
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.applyLoadingState(isLoading)
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

    private func applyLoadingState(_ isLoading: Bool) {
        if isLoading {
            skeletonView.startAnimating()
            tableView.isHidden = true
            emptyTeamsView.isHidden = true
        } else {
            skeletonView.stopAnimating()
            updateView()
        }
    }

    private func updateView() {
        guard !viewModel.isLoading else { return }
        tableView.reloadData()
        let hasTeams = !viewModel.teams.isEmpty
        emptyTeamsView.isHidden = hasTeams
        tableView.isHidden = !hasTeams
    }

    // MARK: - Actions

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
        return viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = viewModel.teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(TeamTableViewCell.self, for: indexPath)

        let logo = UIImage(named: team.logo)
        cell.delegate = self
        cell.configure(with: team, logo: logo)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !viewModel.teams.isEmpty else {
            return nil
        }

        let containerHeader = UIView().background(.appBackground)
        LayoutPresets.titleLabel(text: "Mis Equipos Favoritos", fontSize: 18)
            .addTo(containerHeader)
            .pinLeading(constant: Spacing.standard)
            .pinTop(constant: Spacing.small)
            .pinBottom(constant: Spacing.small)

        return containerHeader
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.teams.isEmpty ? 0 : 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - TeamTableViewCellDelegate

extension FavoritosViewController: TeamTableViewCellDelegate {
    func didTapFavorite(cell: TeamTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let team = viewModel.teams[indexPath.row]
        let teamCode = team.logo.lowercased()
        viewModel.toggleFavoriteTeam(teamId: teamCode)
    }
}

// MARK: - TeamSearchModalDelegate

extension FavoritosViewController: TeamSearchModalDelegate {
    func didSelectTeam(_ team: TeamUI) {
        let teamCode = team.logo.lowercased()
        viewModel.toggleFavoriteTeam(teamId: teamCode)
    }
}
