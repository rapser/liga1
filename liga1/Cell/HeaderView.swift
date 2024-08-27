//
//  HeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit

class HeaderView: UIView {

    private let nombreLabel = UILabel()
    private let partidosJugadosLabel = UILabel()
    private let partidosGanadosLabel = UILabel()
    private let partidosEmpatadosLabel = UILabel()
    private let partidosPerdidosLabel = UILabel()
    private let golesFavorLabel = UILabel()
    private let golesContraLabel = UILabel()
    private let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configura las etiquetas
        nombreLabel.text = "Equipos"
        partidosJugadosLabel.text = "J"
        partidosGanadosLabel.text = "G"
        partidosEmpatadosLabel.text = "E"
        partidosPerdidosLabel.text = "P"
        golesFavorLabel.text = "GF"
        golesContraLabel.text = "GC"
        puntosLabel.text = "Ptos"

        // Configura la apariencia de las etiquetas
        let labels = [nombreLabel, partidosJugadosLabel, partidosGanadosLabel, partidosEmpatadosLabel, partidosPerdidosLabel, golesFavorLabel, golesContraLabel, puntosLabel]
        for label in labels {
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textAlignment = .center
        }
        
        // Configura el stack view
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Añade las etiquetas al stack view
        stackView.addArrangedSubview(nombreLabel)
        stackView.addArrangedSubview(partidosJugadosLabel)
        stackView.addArrangedSubview(partidosGanadosLabel)
        stackView.addArrangedSubview(partidosEmpatadosLabel)
        stackView.addArrangedSubview(partidosPerdidosLabel)
        stackView.addArrangedSubview(golesFavorLabel)
        stackView.addArrangedSubview(golesContraLabel)
        stackView.addArrangedSubview(puntosLabel)
        
        // Añade el stack view a la vista
        addSubview(stackView)
        
        // Configura las constraints del stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalToConstant: 35),
            
            // Ajusta los constraints de cada etiqueta
            nombreLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.35),
            partidosJugadosLabel.widthAnchor.constraint(equalTo: partidosGanadosLabel.widthAnchor),
            partidosGanadosLabel.widthAnchor.constraint(equalTo: partidosEmpatadosLabel.widthAnchor),
            partidosEmpatadosLabel.widthAnchor.constraint(equalTo: partidosPerdidosLabel.widthAnchor),
            partidosPerdidosLabel.widthAnchor.constraint(equalTo: golesFavorLabel.widthAnchor),
            golesFavorLabel.widthAnchor.constraint(equalTo: golesContraLabel.widthAnchor),
            golesContraLabel.widthAnchor.constraint(equalTo: puntosLabel.widthAnchor),
        ])
    }
}

