//
//  HeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class HeaderView: UIView {

    private lazy var posicionLabel = UILabel()
    private lazy var equipoLabel = UILabel()
    private lazy var partidosJugadosLabel = UILabel()
    private lazy var golesLabel = UILabel()
    private lazy var puntosLabel = UILabel()

    private lazy var stackView = UIStackView()
        .prepareForAutoLayout()
        .axis(.horizontal)
        .alignment(.center)
        .spacing(Spacing.tiny)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // Configurar textos
        posicionLabel.text("#")
        equipoLabel.text("Equipo")
        partidosJugadosLabel.text("PJ")
        golesLabel.text("G")
        puntosLabel.text("PTS")

        // Configurar estilos para todos los labels
        let labels = [posicionLabel, equipoLabel, partidosJugadosLabel, golesLabel, puntosLabel]
        labels.forEach {
            $0.font(.boldSystemFont(ofSize: 12))
            $0.alignment(.center)
        }
        equipoLabel.alignment(.left)

        // Agregar labels al stack
        stackView.addArranged([
            posicionLabel,
            equipoLabel,
            partidosJugadosLabel,
            golesLabel,
            puntosLabel
        ])

        // Agregar stack a la vista
        stackView
            .addTo(self)
            .pinHorizontal(padding: Spacing.small)
            .pinVertical(padding: Spacing.tiny)

        // Anchos específicos
        posicionLabel.width(25)
        partidosJugadosLabel.width(30)
        golesLabel.width(60)
        puntosLabel.width(40)
    }
}
