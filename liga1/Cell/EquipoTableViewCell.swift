//
//  EquipoTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class EquipoTableViewCell: UITableViewCell {
    
    private let stackView = UIStackView()
    
    private let posicionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let partidosJugadosLabel = createValueLabel()
    private let golesLabel = createValueLabel()
    private let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Equipo stack → logo + nombre
        let equipoStack = UIStackView(arrangedSubviews: [logoImageView, nombreLabel])
        equipoStack.axis = .horizontal
        equipoStack.spacing = 4
        equipoStack.alignment = .center

        stackView.addArrangedSubview(posicionLabel)
        stackView.addArrangedSubview(equipoStack)
        stackView.addArrangedSubview(partidosJugadosLabel)
        stackView.addArrangedSubview(golesLabel)
        stackView.addArrangedSubview(puntosLabel)

        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            posicionLabel.widthAnchor.constraint(equalToConstant: 25),
            partidosJugadosLabel.widthAnchor.constraint(equalToConstant: 30),
            golesLabel.widthAnchor.constraint(equalToConstant: 60),
            puntosLabel.widthAnchor.constraint(equalToConstant: 40),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 20),
            logoImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with model: Team, position: Int) {
        posicionLabel.text = "\(position)."
        logoImageView.image = UIImage(named: model.logo)
        nombreLabel.text = model.nombre
        partidosJugadosLabel.text = "\(model.partidosJugados)"
        golesLabel.text = "\(model.golesFavor) - \(model.golesContra)"
        puntosLabel.text = "\(model.puntos)"
    }
    
    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }
}
