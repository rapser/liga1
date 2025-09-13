//
//  EquipoTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class EquipoTableViewCell: UITableViewCell {
    
    private let stackView = UIStackView()
    
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
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2 // Adjust spacing as needed
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalToConstant: 35),
            
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
            
            nombreLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.35),
            
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
