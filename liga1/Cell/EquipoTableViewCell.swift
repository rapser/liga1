//
//  EquipoTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class EquipoTableViewCell: UITableViewCell {
    
    private let stackView = UIStackView()
    
    // Labels
    let nombreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    let partidosJugadosLabel: UILabel = createValueLabel()
    let partidosGanadosLabel: UILabel = createValueLabel()
    let partidosEmpatadosLabel: UILabel = createValueLabel()
    let partidosPerdidosLabel: UILabel = createValueLabel()
    let golesFavorLabel: UILabel = createValueLabel()
    let golesContraLabel: UILabel = createValueLabel()
    let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure stack view
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2 // Adjust spacing as needed
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels to stack view
        stackView.addArrangedSubview(nombreLabel)
        stackView.addArrangedSubview(partidosJugadosLabel)
        stackView.addArrangedSubview(partidosGanadosLabel)
        stackView.addArrangedSubview(partidosEmpatadosLabel)
        stackView.addArrangedSubview(partidosPerdidosLabel)
        stackView.addArrangedSubview(golesFavorLabel)
        stackView.addArrangedSubview(golesContraLabel)
        stackView.addArrangedSubview(puntosLabel)
        
        // Add stack view to content view
        contentView.addSubview(stackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalToConstant: 35),
            
            // Ensure stack view occupies 100% of the cell's width minus the right margin
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16), // Adjust for leading and trailing margins
            
            // Ensure nombreLabel occupies 35% of the stack view's width
            nombreLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.35),
            
            // Ensure remaining labels are evenly distributed within the remaining 65% of the width
            partidosJugadosLabel.widthAnchor.constraint(equalTo: partidosGanadosLabel.widthAnchor),
            partidosGanadosLabel.widthAnchor.constraint(equalTo: partidosEmpatadosLabel.widthAnchor),
            partidosEmpatadosLabel.widthAnchor.constraint(equalTo: partidosPerdidosLabel.widthAnchor),
            partidosPerdidosLabel.widthAnchor.constraint(equalTo: golesFavorLabel.widthAnchor),
            golesFavorLabel.widthAnchor.constraint(equalTo: golesContraLabel.widthAnchor),
            golesContraLabel.widthAnchor.constraint(equalTo: puntosLabel.widthAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: Match) {
        nombreLabel.text = model.nombre
        partidosJugadosLabel.text = "\(model.partidosJugados)"
        partidosGanadosLabel.text = "\(model.partidosGanados)"
        partidosEmpatadosLabel.text = "\(model.partidosEmpatados)"
        partidosPerdidosLabel.text = "\(model.partidosPerdidos)"
        golesFavorLabel.text = "\(model.golesFavor)"
        golesContraLabel.text = "\(model.golesContra)"
        puntosLabel.text = "\(model.puntos)"
    }
    
    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }
}

class EquipoTableViewCell2: UITableViewCell {

    let nombreLabel = UILabel()
    
    let partidosJugadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let partidosGanadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let partidosEmpatadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let partidosPerdidosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let golesFavorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let golesContraLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configura la UI de la celda
    private func configureUI() {
        contentView.addConstraints(to: nombreLabel, leading: 10, top: 10, width: 150)
        contentView.addConstraints(to: partidosJugadosLabel, leading: 170, top: 10, width: 20)
        contentView.addConstraints(to: partidosGanadosLabel, leading: 200, top: 10, width: 20)
        contentView.addConstraints(to: partidosEmpatadosLabel, leading: 230, top: 10, width: 20)
        contentView.addConstraints(to: partidosPerdidosLabel, leading: 260, top: 10, width: 20)
        contentView.addConstraints(to: puntosLabel, leading: 290, top: 10, width: 20)
        contentView.addConstraints(to: golesFavorLabel, leading: 320, top: 10, width: 20)
        contentView.addConstraints(to: golesContraLabel, top: 10, trailing: 10, width: 30)

    }

    // Método para configurar la celda con los datos del equipo
    func configurarCon(equipo: Match) {
        nombreLabel.text = equipo.nombre
        partidosJugadosLabel.text = "\(equipo.partidosJugados)"
        partidosGanadosLabel.text = "\(equipo.partidosGanados)"
        partidosEmpatadosLabel.text = "\(equipo.partidosEmpatados)"
        partidosPerdidosLabel.text = "\(equipo.partidosPerdidos)"
        golesFavorLabel.text = "\(equipo.golesFavor)"
        golesContraLabel.text = "\(equipo.golesContra)"
        puntosLabel.text = "\(equipo.puntos)"
    }
}
