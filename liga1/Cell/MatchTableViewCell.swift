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
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(estrellaImageView)
        contentView.addSubview(logoLocalImageView)
        contentView.addSubview(nombreLocalLabel)
        contentView.addSubview(logoVisitanteImageView)
        contentView.addSubview(nombreVisitanteLabel)
        contentView.addSubview(horaLabel)
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
            estrellaImageView.widthAnchor.constraint(equalToConstant: 30),
            estrellaImageView.heightAnchor.constraint(equalToConstant: 30),
            
            // Logo local
            logoLocalImageView.leadingAnchor.constraint(equalTo: estrellaImageView.trailingAnchor, constant: 8),
            logoLocalImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            logoLocalImageView.widthAnchor.constraint(equalToConstant: 20),
            logoLocalImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Nombre local
            nombreLocalLabel.leadingAnchor.constraint(equalTo: logoLocalImageView.trailingAnchor, constant: 8),
            nombreLocalLabel.centerYAnchor.constraint(equalTo: logoLocalImageView.centerYAnchor),
            
            // Hora centrada verticalmente respecto a toda la celda
            horaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            horaLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Logo visitante
            logoVisitanteImageView.leadingAnchor.constraint(equalTo: logoLocalImageView.leadingAnchor),
            logoVisitanteImageView.topAnchor.constraint(equalTo: logoLocalImageView.bottomAnchor, constant: 8),
            logoVisitanteImageView.widthAnchor.constraint(equalToConstant: 20),
            logoVisitanteImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Nombre visitante
            nombreVisitanteLabel.leadingAnchor.constraint(equalTo: logoVisitanteImageView.trailingAnchor, constant: 8),
            nombreVisitanteLabel.centerYAnchor.constraint(equalTo: logoVisitanteImageView.centerYAnchor),
            nombreVisitanteLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Config
    func configure(with match: Match, logoLocal: UIImage?, logoVisitante: UIImage?) {
        nombreLocalLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoLocalId)
        nombreVisitanteLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoVisitanteId)
        logoLocalImageView.image = logoLocal
        logoVisitanteImageView.image = logoVisitante
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        horaLabel.text = formatter.string(from: match.fecha)
    }
}
