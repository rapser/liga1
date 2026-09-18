//
//  MatchTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//  Refactored on 31/01/26.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    // MARK: - UI Components

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
        .alignment(.center)
        .lines(2)
        .textColor(.secondaryLabel)
        .prepareForAutoLayout()

    private let estadoSeparatorView = UIView()
        .background(.separator)
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
        setupMarcadoresYHora()

        equiposStackView
            .addTo(contentView)
            .pinLeading(constant: 20)
            .pinTrailing(to: marcadorLocalLabel.leadingAnchor, constant: Spacing.small)
            .pinTop(constant: 12)
            .pinBottom(constant: 12)

        equiposStackView.addArrangedSubview(equipoLocalContainer)
        equiposStackView.addArrangedSubview(equipoVisitanteContainer)

        setupEquipoLocal()
        setupEquipoVisitante()
    }

    private func setupMarcadoresYHora() {
        horaLabel
            .addTo(contentView)
            .pinTrailing(constant: Spacing.medium)
            .centerY()
            .width(58)

        estadoSeparatorView
            .addTo(contentView)
            .pinTrailing(to: horaLabel.leadingAnchor, constant: Spacing.small)
            .centerY()
            .width(1)
            .height(44)

        marcadorLocalLabel
            .addTo(contentView)
            .pinTrailing(to: estadoSeparatorView.leadingAnchor, constant: Spacing.medium)
            .pinTop(constant: 12)
            .width(28)

        marcadorVisitanteLabel
            .addTo(contentView)
            .pinTrailing(to: estadoSeparatorView.leadingAnchor, constant: Spacing.medium)
            .pinBottom(constant: 12)
            .width(28)
    }

    private func setupEquipoLocal() {
        logoLocalImageView
            .addTo(equipoLocalContainer)
            .pinLeading()
            .centerY()
            .square(24)

        nombreLocalLabel
            .addTo(equipoLocalContainer)
            .pinLeading(to: logoLocalImageView.trailingAnchor, constant: Spacing.small)
            .pinTrailing()
            .centerY()
    }

    private func setupEquipoVisitante() {
        logoVisitanteImageView
            .addTo(equipoVisitanteContainer)
            .pinLeading()
            .centerY()
            .square(24)

        nombreVisitanteLabel
            .addTo(equipoVisitanteContainer)
            .pinLeading(to: logoVisitanteImageView.trailingAnchor, constant: Spacing.small)
            .pinTrailing()
            .centerY()
    }

    // MARK: - Config

    func configure(with matchUI: MatchUI, logoLocal: UIImage?, logoVisitante: UIImage?) {
        nombreLocalLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: matchUI.equipoLocalId ?? "shield.fill")
        nombreVisitanteLabel.text = EquipoPeruano.obtenerNombreCompleto(paraId: matchUI.equipoVisitanteId ?? "shield.fill")
        logoLocalImageView.image = logoLocal
        logoVisitanteImageView.image = logoVisitante

        switch matchUI.estado {
        case .pendiente:
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeFormatter.locale = Locale(identifier: "es_PE")
            let timeString = timeFormatter.string(from: matchUI.fecha)

            marcadorLocalLabel.isHidden = true
            marcadorVisitanteLabel.isHidden = true
            estadoSeparatorView.isHidden = true
            horaLabel.isHidden = false
            horaLabel.text = timeString
            horaLabel.textColor = .secondaryLabel
            horaLabel.font = .systemFont(ofSize: 11, weight: .regular)

        case .envivo:
            marcadorLocalLabel.isHidden = false
            marcadorVisitanteLabel.isHidden = false
            estadoSeparatorView.isHidden = false
            horaLabel.isHidden = false
            horaLabel.text = "EN VIVO\n\(matchUI.minutoActual ?? "–")"
            horaLabel.textColor = .systemGreen
            horaLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            marcadorLocalLabel.text = "\(matchUI.golesEquipoLocal)"
            marcadorVisitanteLabel.text = "\(matchUI.golesEquipoVisitante)"
            marcadorLocalLabel.textColor = .label
            marcadorVisitanteLabel.textColor = .label

        case .finalizado:
            marcadorLocalLabel.isHidden = false
            marcadorVisitanteLabel.isHidden = false
            estadoSeparatorView.isHidden = false
            horaLabel.isHidden = false
            horaLabel.text = "FINAL"
            horaLabel.textColor = .secondaryLabel
            horaLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            marcadorLocalLabel.text = "\(matchUI.golesEquipoLocal)"
            marcadorVisitanteLabel.text = "\(matchUI.golesEquipoVisitante)"
            marcadorLocalLabel.textColor = .label
            marcadorVisitanteLabel.textColor = .label

        case .anulado, .suspendido:
            marcadorLocalLabel.isHidden = false
            marcadorVisitanteLabel.isHidden = false
            estadoSeparatorView.isHidden = false
            horaLabel.isHidden = false
            horaLabel.text = matchUI.estado == .suspendido ? "SUSP." : "ANULADO"
            horaLabel.textColor = .systemRed
            horaLabel.font = .systemFont(ofSize: 10, weight: .semibold)
            marcadorLocalLabel.text = "X"
            marcadorVisitanteLabel.text = "X"
            marcadorLocalLabel.textColor = .systemRed
            marcadorVisitanteLabel.textColor = .systemRed
        }
    }
}
