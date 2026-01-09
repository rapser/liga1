//
//  HomeTableViewAdapter.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import UIKit

/// Protocolo para comunicar eventos del adapter al ViewController
protocol HomeTableViewAdapterDelegate: AnyObject {
    func didTapFavorite(matchId: String, in jornadaId: String)
}

/// Adapter para separar la lógica de TableView del HomeViewController
final class HomeTableViewAdapter: NSObject {

    // MARK: - Properties

    private weak var tableView: UITableView?
    private var sections: [HomeViewModel.JornadaSection] = []
    weak var delegate: HomeTableViewAdapterDelegate?

    // MARK: - Initialization

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }

    // MARK: - Public Methods

    func update(with sections: [HomeViewModel.JornadaSection]) {
        self.sections = sections
        tableView?.reloadData()
    }

    // MARK: - Private Methods

    private func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource

extension HomeTableViewAdapter: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = sections[indexPath.section].matches[indexPath.row]
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
}

// MARK: - UITableViewDelegate

extension HomeTableViewAdapter: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let jornadaSection = sections[section]
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

extension HomeTableViewAdapter: MatchTableViewCellDelegate {
    func didTapFavorite(cell: MatchTableViewCell) {
        guard let tableView = tableView,
              let indexPath = tableView.indexPath(for: cell) else { return }

        let jornadaSection = sections[indexPath.section]
        let match = jornadaSection.matches[indexPath.row]

        // El ID completo incluye la jornada: "clausura_01_adt_utc"
        let fullMatchId = "\(jornadaSection.jornadaId)_\(match.id)"

        delegate?.didTapFavorite(matchId: fullMatchId, in: jornadaSection.jornadaId)
    }
}
