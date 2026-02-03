//
//  MatchTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//  Refactored on 31/01/26.
//

import UIKit

protocol MatchTableViewCellDelegate: AnyObject {
    func didTapFavorite(cell: MatchTableViewCell)
}

class MatchTableViewCell: UITableViewCell {

    static let identifier = "MatchTableViewCell"
    weak var delegate: MatchTableViewCellDelegate?

    // MARK: - UI Components

    private lazy var estrellaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.prepareForAutoLayout()
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.tintColor = .systemYellow
        btn.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var equiposStackView: UIStackView = {
        let stack = UIStackView()
        stack.prepareForAutoLayout()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // Equipo Local
    private lazy var equipoLocalContainer: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        return view
    }()

    private lazy var logoLocalImageView: UIImageView = {
        let iv = UIImageView()
        iv.prepareForAutoLayout()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var nombreLocalLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var marcadorLocalLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    // Equipo Visitante
    private lazy var equipoVisitanteContainer: UIView = {
        let view = UIView()
        view.prepareForAutoLayout()
        return view
    }()

    private lazy var logoVisitanteImageView: UIImageView = {
        let iv = UIImageView()
        iv.prepareForAutoLayout()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var nombreVisitanteLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private lazy var marcadorVisitanteLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var horaLabel: UILabel = {
        let label = UILabel()
        label.prepareForAutoLayout()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        // Estrella a la izquierda
        estrellaButton
            .addTo(contentView)
            .pinLeading(constant: Spacing.small)
            .centerY()
            .square(32)

        // Stack vertical con los dos equipos
        equiposStackView
            .addTo(contentView)
            .pinLeading(to: estrellaButton.trailingAnchor, constant: Spacing.small)
            .pinTop(constant: 12)
            .pinBottom(constant: 12)

        // Agregar containers al stack
        equiposStackView.addArrangedSubview(equipoLocalContainer)
        equiposStackView.addArrangedSubview(equipoVisitanteContainer)

        // Setup Equipo Local
        setupEquipoLocal()

        // Setup Equipo Visitante
        setupEquipoVisitante()

        // Label de hora (centrado verticalmente)
        horaLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.small)
            .centerY()
            .width(65)
    }

    private func setupEquipoLocal() {
        // Logo
        logoLocalImageView
            .addTo(equipoLocalContainer)
            .pinLeading()
            .centerY()
            .square(24)

        // Nombre
        nombreLocalLabel
            .addTo(equipoLocalContainer)
            .pinLeading(to: logoLocalImageView.trailingAnchor, constant: Spacing.small)
            .centerY()

        // Marcador
        marcadorLocalLabel
            .addTo(equipoLocalContainer)
            .pinTrailing()
            .centerY()
            .width(30)

        // Restricción para evitar overlap
        nombreLocalLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: marcadorLocalLabel.leadingAnchor,
            constant: -Spacing.small
        ).isActive = true

        // Conectar el trailing del container al stack
        equipoLocalContainer.trailingAnchor.constraint(
            equalTo: equiposStackView.trailingAnchor
        ).isActive = true
    }

    private func setupEquipoVisitante() {
        // Logo
        logoVisitanteImageView
            .addTo(equipoVisitanteContainer)
            .pinLeading()
            .centerY()
            .square(24)

        // Nombre
        nombreVisitanteLabel
            .addTo(equipoVisitanteContainer)
            .pinLeading(to: logoVisitanteImageView.trailingAnchor, constant: Spacing.small)
            .centerY()

        // Marcador
        marcadorVisitanteLabel
            .addTo(equipoVisitanteContainer)
            .pinTrailing()
            .centerY()
            .width(30)

        // Restricción para evitar overlap
        nombreVisitanteLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: marcadorVisitanteLabel.leadingAnchor,
            constant: -Spacing.small
        ).isActive = true

        // Conectar el trailing del container al stack
        equipoVisitanteContainer.trailingAnchor.constraint(
            equalTo: equiposStackView.trailingAnchor
        ).isActive = true
    }

    // MARK: - Actions

    @objc private func favoriteTapped() {
        delegate?.didTapFavorite(cell: self)
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
            // Mostrar la hora del partido
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeFormatter.locale = Locale(identifier: "es_PE")
            let timeString = timeFormatter.string(from: matchUI.fecha)

            // Ocultar marcadores y mostrar hora
            marcadorLocalLabel.isHidden = true
            marcadorVisitanteLabel.isHidden = true
            horaLabel.isHidden = false
            horaLabel.text = timeString

        case .envivo, .finalizado:
            // Mostrar marcadores y ocultar hora
            marcadorLocalLabel.isHidden = false
            marcadorVisitanteLabel.isHidden = false
            horaLabel.isHidden = true
            marcadorLocalLabel.text = "\(matchUI.golesEquipoLocal)"
            marcadorVisitanteLabel.text = "\(matchUI.golesEquipoVisitante)"
            marcadorLocalLabel.textColor = .label
            marcadorVisitanteLabel.textColor = .label

        case .anulado, .suspendido:
            // Mostrar marcadores y ocultar hora
            marcadorLocalLabel.isHidden = false
            marcadorVisitanteLabel.isHidden = false
            horaLabel.isHidden = true
            marcadorLocalLabel.text = "X"
            marcadorVisitanteLabel.text = "X"
            marcadorLocalLabel.textColor = .systemRed
            marcadorVisitanteLabel.textColor = .systemRed
        }
    }
}
