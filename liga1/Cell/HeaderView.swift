//
//  HeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit

class HeaderView: UIView {
    
    private let posicionLabel = UILabel()
    private let equipoLabel = UILabel()
    private let partidosJugadosLabel = UILabel()
    private let golesLabel = UILabel()
    private let puntosLabel = UILabel()
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        posicionLabel.text = "#"
        equipoLabel.text = "Equipo"
        partidosJugadosLabel.text = "PJ"
        golesLabel.text = "G"
        puntosLabel.text = "PTS"
        
        let labels = [posicionLabel, equipoLabel, partidosJugadosLabel, golesLabel, puntosLabel]
        labels.forEach {
            $0.font = UIFont.boldSystemFont(ofSize: 12)
            $0.textAlignment = .center
        }
        equipoLabel.textAlignment = .left
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(posicionLabel)
        stackView.addArrangedSubview(equipoLabel)
        stackView.addArrangedSubview(partidosJugadosLabel)
        stackView.addArrangedSubview(golesLabel)
        stackView.addArrangedSubview(puntosLabel)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            posicionLabel.widthAnchor.constraint(equalToConstant: 25),
            partidosJugadosLabel.widthAnchor.constraint(equalToConstant: 30),
            golesLabel.widthAnchor.constraint(equalToConstant: 60),
            puntosLabel.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}
