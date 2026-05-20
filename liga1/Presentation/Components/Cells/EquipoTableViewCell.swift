//
//  EquipoTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

class EquipoTableViewCell: UITableViewCell {

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Spacing.tiny
        stack.prepareForAutoLayout()
        return stack
    }()

    private lazy var posicionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.prepareForAutoLayout()
        return imageView
    }()

    private lazy var nombreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var partidosJugadosLabel = Self.createValueLabel()
    private lazy var golesLabel = Self.createValueLabel()

    private lazy var puntosLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
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
        // Equipo stack → logo + nombre
        let equipoStack = UIStackView.hStack(spacing: Spacing.tiny, alignment: .center) {
            [logoImageView, nombreLabel]
        }

        // Stack principal con todos los elementos
        stackView.addArranged([
            posicionLabel,
            equipoStack,
            partidosJugadosLabel,
            golesLabel,
            puntosLabel
        ])

        stackView
            .addTo(contentView)
            .pinHorizontal(padding: Spacing.small)
            .pinVertical(padding: Spacing.tiny)

        // Anchos específicos para cada elemento
        posicionLabel.width(25)
        posicionLabel.height(25)
        posicionLabel.clip(true)
        partidosJugadosLabel.width(30)
        golesLabel.width(60)
        puntosLabel.width(40)
        logoImageView.square(20)
    }
    
    func configure(with model: TeamUI, position: Int, positionColor: UIColor? = nil, isChampion: Bool = false) {
        if isChampion {
            posicionLabel.text = "\(position)"
            posicionLabel.backgroundColor = .libertadoresGold
            posicionLabel.textColor = .black
            posicionLabel.font = UIFont.boldSystemFont(ofSize: 13)
            posicionLabel.layer.cornerRadius = 5
            posicionLabel.layer.borderWidth = 0
            posicionLabel.clip(true)
        } else {
            posicionLabel.text = "\(position)."
            posicionLabel.backgroundColor = .clear
            posicionLabel.layer.cornerRadius = 0
            posicionLabel.layer.borderWidth = 0

            if let color = positionColor {
                posicionLabel.textColor = color
                posicionLabel.font = UIFont.boldSystemFont(ofSize: 14)
            } else {
                posicionLabel.textColor = .label
                posicionLabel.font = UIFont.systemFont(ofSize: 12)
            }
        }

        // Cargar logo solo si el nombre no está vacío para evitar el error de CUICatalog
        if !model.logo.isEmpty {
            logoImageView.image = UIImage(named: model.logo)
        } else {
            logoImageView.image = nil
        }
        nombreLabel.text = model.nombre
        partidosJugadosLabel.text = "\(model.partidosJugados)"
        golesLabel.text = "\(model.golesFavor) - \(model.golesContra)"
        puntosLabel.text = "\(model.puntos)"
    }
    
    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }
}
