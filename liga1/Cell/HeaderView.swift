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
    private let diferenciaGolesLabel = UILabel()
//    private let puntosLabel = UILabel()
    
    private let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configura las etiquetas
        nombreLabel.text = "Clausura"
        partidosJugadosLabel.text = "J"
        partidosGanadosLabel.text = "G"
        partidosEmpatadosLabel.text = "E"
        partidosPerdidosLabel.text = "P"
        golesFavorLabel.text = "GF"
        golesContraLabel.text = "GC"
        diferenciaGolesLabel.text = "DG"
        puntosLabel.text = "Ptos"

        // Configura la apariencia
        let labels = [nombreLabel, partidosJugadosLabel, partidosGanadosLabel, partidosEmpatadosLabel, partidosPerdidosLabel, golesFavorLabel, golesContraLabel, diferenciaGolesLabel, puntosLabel]
        for label in labels {
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.textAlignment = .center
            addSubview(label)
        }

        // Configura el auto-layout para las etiquetas usando la extensión
        let labelWidth: CGFloat = 20
        let padding: CGFloat = 10
        
        addConstraints(to: nombreLabel, leading: 10, top: 10, width: 150)
        addConstraints(to: partidosJugadosLabel, leading: 170, top: 10, width: labelWidth)
        addConstraints(to: partidosGanadosLabel, leading: 200, top: 10, width: labelWidth)
        addConstraints(to: partidosEmpatadosLabel, leading: 230, top: 10, width: labelWidth)
        addConstraints(to: partidosPerdidosLabel, leading: 260, top: 10, width: labelWidth)
        addConstraints(to: puntosLabel, leading: 290, top: 10, width: labelWidth)
        addConstraints(to: golesFavorLabel, leading: 320, top: 10, width: labelWidth+5)
        addConstraints(to: golesContraLabel, leading: 350, top: padding, trailing: padding, width: 30)


    }
}
