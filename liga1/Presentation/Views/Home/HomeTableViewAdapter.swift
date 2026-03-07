//
//  HomeTableViewAdapter.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
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
    private var sections: [JornadaSection] = []
    weak var delegate: HomeTableViewAdapterDelegate?

    // MARK: - Initialization

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }

    // MARK: - Public Methods

    func update(with sections: [JornadaSection]) {
        self.sections = sections
        tableView?.reloadData()
    }

    // MARK: - Private Methods

    private func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerCell(MatchTableViewCell.self)
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
        let cell = tableView.dequeueReusableCell(MatchTableViewCell.self, for: indexPath)

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

        let fechaPartido: Date
        if let primerPartido = jornadaSection.matches.first {
            fechaPartido = primerPartido.fecha
        } else {
            fechaPartido = Date()
        }

        let dateHeaderView = UIView()
        dateHeaderView.backgroundColor = .systemBackground

        let fechaDiaLabel = UILabel()
        fechaDiaLabel.text = formatDateForHeader(fechaPartido)
        fechaDiaLabel.font = .systemFont(ofSize: 16)
        fechaDiaLabel.textColor = .label

        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.tintColor = .secondaryLabel
        calendarIcon.contentMode = .scaleAspectFit

        fechaDiaLabel
            .addTo(dateHeaderView)
            .pinLeading(constant: Spacing.standard)
            .centerY()
        calendarIcon
            .addTo(dateHeaderView)
            .square(20)
            .pinTrailing(constant: Spacing.standard)
            .centerY()

        let jornadaHeaderView = UIView()
        jornadaHeaderView.backgroundColor = .secondarySystemBackground

        let fechaLabel = UILabel()
        fechaLabel.text = "Fecha \(jornadaSection.numero)"
        fechaLabel.font = .boldSystemFont(ofSize: 18)
        fechaLabel.textColor = .label

        let torneoCapitalizado = jornadaSection.torneo.capitalized
        let torneoLabel = UILabel()
        torneoLabel.text = "Liga 1 - \(torneoCapitalizado) 2026"
        torneoLabel.font = .systemFont(ofSize: 14)
        torneoLabel.textColor = .secondaryLabel

        fechaLabel
            .addTo(jornadaHeaderView)
            .pinLeading(constant: Spacing.standard)
            .pinTop(constant: Spacing.small)
        torneoLabel
            .addTo(jornadaHeaderView)
            .pinLeading(to: fechaLabel.leadingAnchor)
            .pinTop(to: fechaLabel.bottomAnchor, constant: Spacing.tiny)
            .pinBottom(constant: Spacing.small)

        let containerView = UIView()
        containerView.backgroundColor = .systemBackground

        dateHeaderView
            .addTo(containerView)
            .pinTop()
            .pinLeading()
            .pinTrailing()
            .height(44)
        jornadaHeaderView
            .addTo(containerView)
            .pinTop(to: dateHeaderView.bottomAnchor)
            .pinLeading()
            .pinTrailing()
            .pinBottom()

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 104 // 44 (header fecha) + 60 (header jornada)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    // Helper para formatear la fecha del header
    private func formatDateForHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        
        // Si es hoy, mostrar "Hoy"
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "dd.MM"
            return "Hoy \(formatter.string(from: date))"
        } else {
            // Mostrar día de la semana + fecha
            formatter.dateFormat = "EEEE dd.MM"
            let fechaString = formatter.string(from: date)
            // Capitalizar primera letra
            return fechaString.capitalized
        }
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
