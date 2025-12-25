//
//  HomeViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
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

        // Aquí deberías cargar tus logos según el equipo
        let logoLocal = UIImage(named: match.equipoLocalId)
        let logoVisitante = UIImage(named: match.equipoVisitanteId)

        cell.delegate = self
        cell.configure(with: match, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemBackground

        let fechaLabel = UILabel()
        fechaLabel.font = .boldSystemFont(ofSize: 18)
        fechaLabel.textColor = .label
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false
        fechaLabel.text = "Fecha 8"

        let torneoLabel = UILabel()
        torneoLabel.font = .systemFont(ofSize: 14)
        torneoLabel.textColor = .secondaryLabel
        torneoLabel.translatesAutoresizingMaskIntoConstraints = false
        torneoLabel.text = "Liga 1 - Clausura 2025"

        view.addSubview(fechaLabel)
        view.addSubview(torneoLabel)

        NSLayoutConstraint.activate([
            fechaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fechaLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),

            torneoLabel.leadingAnchor.constraint(equalTo: fechaLabel.leadingAnchor),
            torneoLabel.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 4),
            torneoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

// MARK: - MatchTableViewCellDelegate
extension HomeViewController: MatchTableViewCellDelegate {
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
