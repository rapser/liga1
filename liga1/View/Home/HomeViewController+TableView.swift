//
//  HomeViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return jornadaSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jornadaSections[section].matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = jornadaSections[indexPath.section].matches[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        // Cargar logos según el equipo (usando optional binding)
        let logoLocal = match.equipoLocalId.flatMap { UIImage(named: $0) }
        let logoVisitante = match.equipoVisitanteId.flatMap { UIImage(named: $0) }

        cell.delegate = self
        cell.configure(with: match, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let jornadaSection = jornadaSections[section]
        let view = UIView()
        view.backgroundColor = .systemBackground

        let fechaLabel = UILabel()
        fechaLabel.font = .boldSystemFont(ofSize: 18)
        fechaLabel.textColor = .label
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false
        fechaLabel.text = "Fecha \(jornadaSection.numero)"

        let torneoLabel = UILabel()
        torneoLabel.font = .systemFont(ofSize: 14)
        torneoLabel.textColor = .secondaryLabel
        torneoLabel.translatesAutoresizingMaskIntoConstraints = false

        // Capitalizar torneo (clausura -> Clausura)
        let torneoCapitalizado = jornadaSection.torneo.capitalized
        torneoLabel.text = "Liga 1 - \(torneoCapitalizado) 2026"

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
        let jornadaSection = jornadaSections[indexPath.section]
        let match = jornadaSection.matches[indexPath.row]

        guard let matchId = match.id else { return }

        // El ID completo incluye la jornada: "clausura_01_adt_utc"
        let fullMatchId = "\(jornadaSection.jornadaId)_\(matchId)"

        FavoritesManager.shared.toggleFavorite(matchId: fullMatchId) { isFavorite, error in
            if let error = error {
                print("Error toggling favorite: \(error)")
                return
            }

            // La UI se actualizará automáticamente mediante el listener
        }
    }
}
