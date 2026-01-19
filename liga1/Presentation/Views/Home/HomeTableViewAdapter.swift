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
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground

        // Header superior: Fecha del día con icono de calendario
        let dateHeaderView = UIView()
        dateHeaderView.backgroundColor = .systemBackground
        dateHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        let fechaDiaLabel = UILabel()
        fechaDiaLabel.font = .systemFont(ofSize: 16)
        fechaDiaLabel.textColor = .label
        fechaDiaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Obtener la fecha del primer partido
        let fechaPartido: Date
        if let primerPartido = jornadaSection.matches.first {
            fechaPartido = primerPartido.fecha
        } else {
            fechaPartido = Date() // Fallback si no hay partidos
        }
        
        // Formatear la fecha
        fechaDiaLabel.text = formatDateForHeader(fechaPartido)
        
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.tintColor = .secondaryLabel
        calendarIcon.contentMode = .scaleAspectFit
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        dateHeaderView.addSubview(fechaDiaLabel)
        dateHeaderView.addSubview(calendarIcon)
        
        NSLayoutConstraint.activate([
            fechaDiaLabel.leadingAnchor.constraint(equalTo: dateHeaderView.leadingAnchor, constant: 16),
            fechaDiaLabel.centerYAnchor.constraint(equalTo: dateHeaderView.centerYAnchor),
            
            calendarIcon.trailingAnchor.constraint(equalTo: dateHeaderView.trailingAnchor, constant: -16),
            calendarIcon.centerYAnchor.constraint(equalTo: dateHeaderView.centerYAnchor),
            calendarIcon.widthAnchor.constraint(equalToConstant: 20),
            calendarIcon.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Header inferior: Fecha de jornada y torneo
        let jornadaHeaderView = UIView()
        // Fondo sutil para diferenciar del header superior (se adapta a modo claro/oscuro)
        jornadaHeaderView.backgroundColor = .secondarySystemBackground
        jornadaHeaderView.translatesAutoresizingMaskIntoConstraints = false

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

        jornadaHeaderView.addSubview(fechaLabel)
        jornadaHeaderView.addSubview(torneoLabel)

        NSLayoutConstraint.activate([
            fechaLabel.leadingAnchor.constraint(equalTo: jornadaHeaderView.leadingAnchor, constant: 16),
            fechaLabel.topAnchor.constraint(equalTo: jornadaHeaderView.topAnchor, constant: 8),

            torneoLabel.leadingAnchor.constraint(equalTo: fechaLabel.leadingAnchor),
            torneoLabel.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 4),
            torneoLabel.bottomAnchor.constraint(equalTo: jornadaHeaderView.bottomAnchor, constant: -8)
        ])

        // Agregar ambos headers al contenedor
        containerView.addSubview(dateHeaderView)
        containerView.addSubview(jornadaHeaderView)

        NSLayoutConstraint.activate([
            dateHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dateHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dateHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dateHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            jornadaHeaderView.topAnchor.constraint(equalTo: dateHeaderView.bottomAnchor),
            jornadaHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            jornadaHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            jornadaHeaderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 104 // 44 (header fecha) + 60 (header jornada)
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
