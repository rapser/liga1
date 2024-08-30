//
//  MatchTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 30/08/24.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    // Elementos de la celda (etiquetas, imágenes, etc.)
    private let team1LogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let team1NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let team2NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let team2LogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let estadoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        // Inicialmente, oculta el label
        label.isHidden = true
        return label
    }()
    
    // StackView para organizar los elementos
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            team1LogoImageView,
            team1NameLabel,
            scoreLabel,
            team2NameLabel,
            team2LogoImageView
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Agregar el StackView a la celda
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with partido: Partido) {
        // Asumiendo que tienes una forma de obtener los nombres y logos de los equipos a partir de los IDs
        team1NameLabel.text = obtenerNombreEquipo(porId: partido.teamAId)
        team2NameLabel.text = obtenerNombreEquipo(porId: partido.teamBId)
        scoreLabel.text = "\(partido.golesTeamA) - \(partido.golesTeamB)"
        
        // Asignar las imágenes a las ImageViews
        team1LogoImageView.image = UIImage(named: partido.teamAId)
        team2LogoImageView.image = UIImage(named: partido.teamBId)
        
        // Configurar el label de estado
        estadoLabel.text = partido.estado.rawValue.capitalized
        estadoLabel.isHidden = false
        
        // Aplicar el color de texto según el estado
        switch partido.estado {
        case .pendiente:
            estadoLabel.textColor = .systemGray
        case .enJuego:
            estadoLabel.textColor = .systemGreen
        case .finalizado:
            estadoLabel.textColor = .systemGray
        }
    }
    
    // Función auxiliar para obtener el nombre del equipo por su ID
    private func obtenerNombreEquipo(porId: String) -> String {
        // Aquí implementarías la lógica para obtener el nombre del equipo a partir de su ID
        // Por ejemplo, podrías hacer una consulta a una base de datos o a una API
        return "Equipo \(porId)" // Placeholder
    }
}
