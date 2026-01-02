//
//  FavoritosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 24/12/24.
//

import UIKit
import Combine

class FavoritosViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel = FavoritosViewModel()
    private var cancellables = Set<AnyCancellable>()

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
        bindViewModel()
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

    private func bindViewModel() {
        viewModel.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.tableView.reloadData()
                self?.updateEmptyState()
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

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !viewModel.matches.isEmpty
        tableView.isHidden = viewModel.matches.isEmpty
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritosViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = viewModel.matches[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        let logoLocal = UIImage(named: match.equipoLocalId ?? "shield.fill")
        let logoVisitante = UIImage(named: match.equipoVisitanteId ?? "shield.fill")

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
        return viewModel.matches.isEmpty ? 0 : 50
    }
}

// MARK: - MatchTableViewCellDelegate
extension FavoritosViewController: MatchTableViewCellDelegate {
    func didTapFavorite(cell: MatchTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let match = viewModel.matches[indexPath.row]

        guard let matchId = match.id else { return }

        viewModel.toggleFavorite(matchId: matchId)
    }
}
