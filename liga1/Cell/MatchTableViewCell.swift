//
//  MatchTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    static let identifier = "MatchTableViewCell"
    
    let estrellaImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star")
        iv.tintColor = .systemYellow
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let logoLocalImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let nombreLocalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let logoVisitanteImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let nombreVisitanteLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let horaLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let marcadorLocalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let marcadorVisitanteLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(estrellaImageView)
        contentView.addSubview(logoLocalImageView)
        contentView.addSubview(nombreLocalLabel)
        contentView.addSubview(logoVisitanteImageView)
        contentView.addSubview(nombreVisitanteLabel)
        contentView.addSubview(horaLabel)
        contentView.addSubview(marcadorLocalLabel)
        contentView.addSubview(marcadorVisitanteLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Estrella centrada verticalmente respecto a toda la celda
            estrellaImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            estrellaImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            estrellaImageView.widthAnchor.constraint(equalToConstant: 24),
            estrellaImageView.heightAnchor.constraint(equalToConstant: 24),

            // Marcador local - pegado a la derecha con padding de 8px
            marcadorLocalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            marcadorLocalLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            marcadorLocalLabel.widthAnchor.constraint(equalToConstant: 30),

            // Logo local
            logoLocalImageView.leadingAnchor.constraint(equalTo: estrellaImageView.trailingAnchor, constant: 12),
            logoLocalImageView.centerYAnchor.constraint(equalTo: marcadorLocalLabel.centerYAnchor),
            logoLocalImageView.widthAnchor.constraint(equalToConstant: 24),
            logoLocalImageView.heightAnchor.constraint(equalToConstant: 24),

            // Nombre local
            nombreLocalLabel.leadingAnchor.constraint(equalTo: logoLocalImageView.trailingAnchor, constant: 8),
            nombreLocalLabel.centerYAnchor.constraint(equalTo: logoLocalImageView.centerYAnchor),
            nombreLocalLabel.trailingAnchor.constraint(lessThanOrEqualTo: marcadorLocalLabel.leadingAnchor, constant: -8),

            // Marcador visitante - pegado a la derecha con padding de 8px
            marcadorVisitanteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            marcadorVisitanteLabel.topAnchor.constraint(equalTo: marcadorLocalLabel.bottomAnchor, constant: 8),
            marcadorVisitanteLabel.widthAnchor.constraint(equalToConstant: 30),

            // Logo visitante
            logoVisitanteImageView.leadingAnchor.constraint(equalTo: logoLocalImageView.leadingAnchor),
            logoVisitanteImageView.centerYAnchor.constraint(equalTo: marcadorVisitanteLabel.centerYAnchor),
            logoVisitanteImageView.widthAnchor.constraint(equalToConstant: 24),
            logoVisitanteImageView.heightAnchor.constraint(equalToConstant: 24),

            // Nombre visitante
            nombreVisitanteLabel.leadingAnchor.constraint(equalTo: logoVisitanteImageView.trailingAnchor, constant: 8),
            nombreVisitanteLabel.centerYAnchor.constraint(equalTo: logoVisitanteImageView.centerYAnchor),
            nombreVisitanteLabel.trailingAnchor.constraint(lessThanOrEqualTo: marcadorVisitanteLabel.leadingAnchor, constant: -8),
            nombreVisitanteLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Config
    func configure(with match: Match, logoLocal: UIImage?, logoVisitante: UIImage?) {
        nombreLocalLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoLocalId)
        nombreVisitanteLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoVisitanteId)
        logoLocalImageView.image = logoLocal
        logoVisitanteImageView.image = logoVisitante

        // Mostrar marcadores según el estado del partido
        switch match.estado {
        case .pendiente:
            marcadorLocalLabel.text = "-"
            marcadorVisitanteLabel.text = "-"
            marcadorLocalLabel.textColor = .secondaryLabel
            marcadorVisitanteLabel.textColor = .secondaryLabel
        case .enJuego, .finalizado:
            marcadorLocalLabel.text = "\(match.golesEquipoLocal)"
            marcadorVisitanteLabel.text = "\(match.golesEquipoVisitante)"
            marcadorLocalLabel.textColor = .label
            marcadorVisitanteLabel.textColor = .label
        case .anulado, .suspendido:
            marcadorLocalLabel.text = "X"
            marcadorVisitanteLabel.text = "X"
            marcadorLocalLabel.textColor = .systemRed
            marcadorVisitanteLabel.textColor = .systemRed
        }
    }
}
