//
//  FanCardView.swift
//  liga1
//
//  Card del rediseño "Fan Experience": fondo elevado, esquinas continuas,
//  encabezado en mayúsculas y borde opcional dorado. Componentes 100% nativos.
//

import UIKit

final class FanCardView: UIView {

    /// Stack vertical para el contenido de la card. El llamador añade sus vistas aquí.
    let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = Spacing.medium
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let headingLabel = UILabel()

    /// - Parameters:
    ///   - title: encabezado en mayúsculas; `nil` = sin encabezado.
    ///   - accentBorder: si es true dibuja un borde dorado sutil (para destacar la card).
    init(title: String?, accentBorder: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSecondaryBackground
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = (accentBorder
            ? UIColor.liga1Gold.withAlphaComponent(0.45)
            : UIColor.cardStroke).cgColor
        self.accentBorder = accentBorder

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = Spacing.small
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.standard),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.standard),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.standard),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.standard)
        ])

        if let title {
            headingLabel.text = title.uppercased()
            headingLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            headingLabel.textColor = .secondaryLabel
            headingLabel.setContentHuggingPriority(.required, for: .vertical)
            container.addArrangedSubview(headingLabel)
            container.setCustomSpacing(Spacing.medium, after: headingLabel)
        }
        container.addArrangedSubview(contentStack)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no soportado") }

    private var accentBorder = false

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        // Refrescar el CGColor del borde no-dorado ante cambio de tema.
        if !accentBorder {
            layer.borderColor = UIColor.cardStroke.cgColor
        }
    }

    // MARK: - Helpers de contenido

    /// Fila "clave / valor" (izquierda label, derecha valor secundario).
    static func infoRow(key: String, value: String, valueColor: UIColor = .secondaryLabel) -> UIView {
        let k = UILabel()
        k.font = .systemFont(ofSize: 14, weight: .medium)
        k.textColor = .label
        k.text = key
        k.setContentCompressionResistancePriority(.required, for: .horizontal)

        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = valueColor
        v.textAlignment = .right
        v.numberOfLines = 0
        v.text = value

        let row = UIStackView(arrangedSubviews: [k, v])
        row.axis = .horizontal
        row.spacing = Spacing.small
        row.alignment = .firstBaseline
        return row
    }

    static func separator() -> UIView {
        let v = UIView()
        v.backgroundColor = .cardStroke
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
}
