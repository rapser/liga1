//
//  TeamSearchModalViewController.swift
//  liga1
//
//  Created by miguel tomairo on 17/01/26.
//

import UIKit
import Combine

protocol TeamSearchModalDelegate: AnyObject {
    func didSelectTeam(_ team: TeamUI)
}

class TeamSearchModalViewController: UIViewController {

    weak var delegate: TeamSearchModalDelegate?

    private var teams: [TeamUI] = []
    private var filteredTeams: [TeamUI] = []
    private var favoriteTeamIds: Set<String> = []

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Buscar Equipo"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Buscar equipo..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .singleLine
        table.keyboardDismissMode = .onDrag
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupGestures()
        searchBar.delegate = self
        filteredTeams = teams
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        containerView
            .addTo(view)
            .pinLeading()
            .pinTrailing()
            .pinBottom()
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true

        handleView
            .addTo(containerView)
            .pinTop(constant: Spacing.small)
            .centerX()
            .size(width: 40, height: 5)

        titleLabel
            .addTo(containerView)
            .pinTop(to: handleView.bottomAnchor, constant: Spacing.medium)
            .pinLeading(constant: Spacing.standard)
            .pinTrailing(constant: Spacing.standard)

        searchBar
            .addTo(containerView)
            .pinTop(to: titleLabel.bottomAnchor, constant: Spacing.medium)
            .pinLeading(constant: Spacing.small)
            .pinTrailing(constant: Spacing.small)

        tableView
            .addTo(containerView)
            .pinTop(to: searchBar.bottomAnchor, constant: Spacing.small)
            .pinLeading()
            .pinTrailing()
            .pinBottom()
    }

    private func setupTableView() {
        tableView.registerCell(TeamTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
    }

    // MARK: - Public Methods

    func configure(teams: [TeamUI], favoriteTeamIds: Set<String>) {
        var teamsWithFavorite = teams
        for index in teamsWithFavorite.indices {
            // IMPORTANTE: Comparar usando logo (código corto) normalizado, no nombre
            let teamCode = teamsWithFavorite[index].logo.lowercased()
            teamsWithFavorite[index].isFavorite = favoriteTeamIds.contains(teamCode)
        }
        self.teams = teamsWithFavorite
        self.filteredTeams = teamsWithFavorite
        self.favoriteTeamIds = favoriteTeamIds
    }

    func updateFavorites(_ favoriteTeamIds: Set<String>) {
        self.favoriteTeamIds = favoriteTeamIds
        for index in filteredTeams.indices {
            // IMPORTANTE: Comparar usando logo (código corto) normalizado, no nombre
            let teamCode = filteredTeams[index].logo.lowercased()
            filteredTeams[index].isFavorite = favoriteTeamIds.contains(teamCode)
        }
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        if translation.y > 0 {
            containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }

        if gesture.state == .ended {
            let velocity = gesture.velocity(in: view)
            if velocity.y > 1000 || translation.y > 200 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = .identity
                }
            }
        }
    }

    private func filterTeams(with searchText: String) {
        if searchText.isEmpty {
            filteredTeams = teams
        } else {
            filteredTeams = teams.filter { team in
                team.nombre.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension TeamSearchModalViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTeams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TeamTableViewCell.self, for: indexPath)

        let team = filteredTeams[indexPath.row]
        let logo = UIImage(named: team.logo)
        cell.delegate = self
        cell.configure(with: team, logo: logo)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - TeamTableViewCellDelegate

extension TeamSearchModalViewController: TeamTableViewCellDelegate {
    func didTapFavorite(cell: TeamTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var team = filteredTeams[indexPath.row]
        
        // Actualizar inmediatamente el estado de la estrella antes de llamar al delegate
        let teamCode = team.logo.lowercased()
        let isCurrentlyFavorite = favoriteTeamIds.contains(teamCode)
        team.isFavorite = !isCurrentlyFavorite
        filteredTeams[indexPath.row] = team
        
        // También actualizar en el array principal si el equipo está ahí
        if let mainIndex = teams.firstIndex(where: { $0.logo.lowercased() == teamCode }) {
            teams[mainIndex].isFavorite = !isCurrentlyFavorite
        }
        
        // Actualizar favoriteTeamIds localmente para reflejar el cambio inmediato
        if isCurrentlyFavorite {
            favoriteTeamIds.remove(teamCode)
        } else {
            favoriteTeamIds.insert(teamCode)
        }
        
        // Recargar solo la celda afectada para actualizar la estrella visualmente
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // Llamar al delegate para que actualice en Firestore
        delegate?.didSelectTeam(team)
    }
}

// MARK: - UISearchBarDelegate

extension TeamSearchModalViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTeams(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
