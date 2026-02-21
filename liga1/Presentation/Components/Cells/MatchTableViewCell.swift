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

    private lazy var equiposStackView = UIStackView()
        .axis(.vertical)
        .spacing(8)
        .distribution(.fillEqually)
        .prepareForAutoLayout()

    // Equipo Local
    private let equipoLocalContainer = UIView().prepareForAutoLayout()
    private let logoLocalImageView = UIImageView()
        .contentMode(.scaleAspectFit)
        .prepareForAutoLayout()
    private let nombreLocalLabel = UILabel()
        .font(.systemFont(ofSize: 14, weight: .medium))
        .prepareForAutoLayout()
    private let marcadorLocalLabel = UILabel()
        .font(.systemFont(ofSize: 16))
        .alignment(.center)
        .prepareForAutoLayout()

    // Equipo Visitante
    private let equipoVisitanteContainer = UIView().prepareForAutoLayout()
    private let logoVisitanteImageView = UIImageView()
        .contentMode(.scaleAspectFit)
        .prepareForAutoLayout()
    private let nombreVisitanteLabel = UILabel()
        .font(.systemFont(ofSize: 14))
        .prepareForAutoLayout()
    private let marcadorVisitanteLabel = UILabel()
        .font(.systemFont(ofSize: 16))
        .alignment(.center)
        .prepareForAutoLayout()

    private let horaLabel = UILabel()
        .font(.systemFont(ofSize: 11, weight: .regular))
        .alignment(.right)
        .textColor(.secondaryLabel)
        .prepareForAutoLayout()

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

        // Stack vertical con los dos equipos - ahora se extiende hasta el final menos un margen
        equiposStackView
            .addTo(contentView)
            .pinLeading(to: estrellaButton.trailingAnchor, constant: Spacing.small)
            .pinTrailing(constant: 80) // Espacio para marcadores/hora
            .pinTop(constant: 12)
            .pinBottom(constant: 12)

        // Agregar containers al stack
        equiposStackView.addArrangedSubview(equipoLocalContainer)
        equiposStackView.addArrangedSubview(equipoVisitanteContainer)

        // Setup Equipo Local
        setupEquipoLocal()

        // Setup Equipo Visitante
        setupEquipoVisitante()

        // Configurar marcadores y hora en el contentView (compartiendo el mismo espacio a la derecha)
        setupMarcadoresYHora()
    }

    private func setupMarcadoresYHora() {
        // Marcador Local - anclado al trailing del contentView
        marcadorLocalLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.small)
            .pinTop(constant: 12)
            .width(40)

        // Marcador Visitante - debajo del marcador local
        marcadorVisitanteLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.small)
            .pinBottom(constant: 12)
            .width(40)

        // Hora - centrada verticalmente, en la misma posición que los marcadores
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

        // Nombre - ocupa todo el espacio disponible
        nombreLocalLabel
            .addTo(equipoLocalContainer)
            .pinLeading(to: logoLocalImageView.trailingAnchor, constant: Spacing.small)
            .pinTrailing()
            .centerY()
    }

    private func setupEquipoVisitante() {
        // Logo
        logoVisitanteImageView
            .addTo(equipoVisitanteContainer)
            .pinLeading()
            .centerY()
            .square(24)

        // Nombre - ocupa todo el espacio disponible
        nombreVisitanteLabel
            .addTo(equipoVisitanteContainer)
            .pinLeading(to: logoVisitanteImageView.trailingAnchor, constant: Spacing.small)
            .pinTrailing()
            .centerY()
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
