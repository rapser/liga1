//
//  SanctionsViewController.swift
//  liga1
//

import UIKit

/// Detalle de las sanciones de puntos que explican la tabla Acumulada.
/// Se abre desde el enlace de la leyenda para no recargar la pantalla de Tabla.
final class SanctionsViewController: UIViewController {

    private let notes: [SanctionNoteUI]
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private static let cellId = "SanctionCell"

    init(notes: [SanctionNoteUI]) {
        self.notes = notes
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(notes:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sanciones"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .appBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .appBackground
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension SanctionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        let note = notes[indexPath.row]

        var content = UIListContentConfiguration.subtitleCell()
        content.image = UIImage(named: note.teamCode)
        content.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        content.imageProperties.reservedLayoutSize = CGSize(width: 32, height: 32)
        content.text = note.teamName
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        content.secondaryText = note.resolution.isEmpty ? "Sanción reglamentaria" : note.resolution
        content.secondaryTextProperties.font = .systemFont(ofSize: 13)
        content.secondaryTextProperties.color = .secondaryLabel
        content.textToSecondaryTextVerticalPadding = 4
        cell.contentConfiguration = content

        let pointsLabel = UILabel()
        pointsLabel.text = note.pointsText
        pointsLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        pointsLabel.textColor = .systemRed
        pointsLabel.sizeToFit()
        cell.accessoryView = pointsLabel
        cell.accessibilityLabel = "\(note.teamName), \(note.points) puntos. \(content.secondaryText ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Descuento de puntos"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Las sanciones solo se descuentan en la tabla Acumulada. Apertura y Clausura muestran los puntos obtenidos en cancha."
    }
}
