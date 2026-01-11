//
//  MatchTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

protocol MatchTableViewCellDelegate: AnyObject {
    func didTapFavorite(cell: MatchTableViewCell)
}

class MatchTableViewCell: UITableViewCell {

    static let identifier = "MatchTableViewCell"
    weak var delegate: MatchTableViewCellDelegate?

    private lazy var estrellaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.prepareForAutoLayout()
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.tintColor = .systemYellow
        return btn
    }()

    private lazy var logoLocalImageView = UIImageView()
        .prepareForAutoLayout()
        .contentMode(.scaleAspectFit)

    private lazy var nombreLocalLabel = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 14, weight: .medium))

    private lazy var logoVisitanteImageView = UIImageView()
        .prepareForAutoLayout()
        .contentMode(.scaleAspectFit)

    private lazy var nombreVisitanteLabel = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 14))

    private lazy var marcadorLocalLabel = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 16, weight: .bold))
        .alignment(.center)

    private lazy var marcadorVisitanteLabel = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 16, weight: .bold))
        .alignment(.center)
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    private func setupActions() {
        estrellaButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    @objc private func favoriteTapped() {
        delegate?.didTapFavorite(cell: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Estrella - centrada verticalmente
        estrellaButton
            .addTo(contentView)
            .pinLeading(constant: Spacing.small)
            .centerY()
            .square(32)

        // Marcador local - alineado a la derecha
        marcadorLocalLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.small)
            .pinTop(constant: Spacing.small)
            .width(30)

        // Logo local
        logoLocalImageView
            .addTo(contentView)
            .pinLeading(to: estrellaButton.trailingAnchor, constant: Spacing.small)
            .centerY(to: marcadorLocalLabel.centerYAnchor)
            .square(24)

        // Nombre local
        nombreLocalLabel
            .addTo(contentView)
            .pinLeading(to: logoLocalImageView.trailingAnchor, constant: Spacing.small)
            .centerY(to: logoLocalImageView.centerYAnchor)

        // Marcador visitante - alineado a la derecha
        marcadorVisitanteLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.small)
            .pinTop(to: marcadorLocalLabel.bottomAnchor, constant: Spacing.small)
            .width(30)

        // Logo visitante
        logoVisitanteImageView
            .addTo(contentView)
            .pinLeading(to: logoLocalImageView.leadingAnchor)
            .centerY(to: marcadorVisitanteLabel.centerYAnchor)
            .square(24)

        // Nombre visitante
        nombreVisitanteLabel
            .addTo(contentView)
            .pinLeading(to: logoVisitanteImageView.trailingAnchor, constant: Spacing.small)
            .centerY(to: logoVisitanteImageView.centerYAnchor)
            .pinBottom(constant: Spacing.small)

        // Restricciones de trailing para los nombres (no deben sobreponerse con marcadores)
        nombreLocalLabel.trailingAnchor.constraint(lessThanOrEqualTo: marcadorLocalLabel.leadingAnchor, constant: -Spacing.small).isActive = true
        nombreVisitanteLabel.trailingAnchor.constraint(lessThanOrEqualTo: marcadorVisitanteLabel.leadingAnchor, constant: -Spacing.small).isActive = true
    }
    
    // MARK: - Config
    func configure(with matchUI: MatchUI, logoLocal: UIImage?, logoVisitante: UIImage?) {
        nombreLocalLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: matchUI.equipoLocalId ?? "shield.fill")
        nombreVisitanteLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: matchUI.equipoVisitanteId ?? "shield.fill")
        logoLocalImageView.image = logoLocal
        logoVisitanteImageView.image = logoVisitante

        // Actualizar estrella de favorito
        let starImage = matchUI.isFavorite ? "star.fill" : "star"
        estrellaButton.setImage(UIImage(systemName: starImage), for: .normal)

        // Mostrar marcadores según el estado del partido
        switch matchUI.estado {
        case .pendiente:
            marcadorLocalLabel.text = "-"
            marcadorVisitanteLabel.text = "-"
            marcadorLocalLabel.textColor = .secondaryLabel
            marcadorVisitanteLabel.textColor = .secondaryLabel
        case .envivo, .finalizado:
            marcadorLocalLabel.text = "\(matchUI.golesEquipoLocal)"
            marcadorVisitanteLabel.text = "\(matchUI.golesEquipoVisitante)"
            marcadorLocalLabel.textColor = .label
            marcadorVisitanteLabel.textColor = .label
        case .anulado, .suspendido:
            marcadorLocalLabel.text = "X"
            marcadorVisitanteLabel.text = "X"
            marcadorLocalLabel.textColor = .systemRed
            marcadorVisitanteLabel.textColor = .systemRed
        }
    }
}
