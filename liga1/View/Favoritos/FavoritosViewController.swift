//
//  FavoritosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 24/12/24.
//

import UIKit
import FirebaseFirestore

class FavoritosViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    var matches: [Match] = []
    var favoriteMatchIds: Set<String> = []
    var favoritesListener: ListenerRegistration?

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No tienes partidos favoritos\nToca la estrella en un partido para agregarlo"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favoritos"

        setupTableView()
        setupEmptyState()
        listenToFavorites()
    }

    deinit {
        favoritesListener?.remove()
    }

    // MARK: - Setup UI
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    // MARK: - Firestore
    private func listenToFavorites() {
        favoritesListener = FavoritesManager.shared.listenToFavorites { [weak self] favoriteIds in
            guard let self = self else { return }
            self.favoriteMatchIds = Set(favoriteIds)
            self.fetchFavoriteMatches()
        }
    }

    private func fetchFavoriteMatches() {
        guard !favoriteMatchIds.isEmpty else {
            self.matches = []
            self.tableView.reloadData()
            self.updateEmptyState()
            return
        }

        let db = Firestore.firestore()

        db.collection("matches")
            .whereField(FieldPath.documentID(), in: Array(favoriteMatchIds))
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching favorite matches: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.matches = documents.compactMap { doc -> Match? in
                    var match = try? doc.data(as: Match.self)
                    match?.isFavorite = true
                    return match
                }

                // Ordenar por fecha
                self.matches.sort { $0.fecha < $1.fecha }
                self.tableView.reloadData()
                self.updateEmptyState()
            }
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !matches.isEmpty
        tableView.isHidden = matches.isEmpty
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritosViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = matches[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        let logoLocal = UIImage(named: match.equipoLocalId)
        let logoVisitante = UIImage(named: match.equipoVisitanteId)

        cell.delegate = self
        cell.configure(with: match, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Mis Partidos Favoritos"

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return matches.isEmpty ? 0 : 50
    }
}

// MARK: - MatchTableViewCellDelegate
extension FavoritosViewController: MatchTableViewCellDelegate {
    func didTapFavorite(cell: MatchTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let match = matches[indexPath.row]

        guard let matchId = match.id else { return }

        FavoritesManager.shared.toggleFavorite(matchId: matchId) { isFavorite, error in
            if let error = error {
                print("Error toggling favorite: \(error)")
                return
            }

            // La UI se actualizará automáticamente mediante el listener
        }
    }
}
