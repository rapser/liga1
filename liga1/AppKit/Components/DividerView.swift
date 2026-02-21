//
//  DividerView.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import UIKit

/// Componente reutilizable para crear un divider con texto centrado entre dos líneas
final class DividerView: UIView {

    // MARK: - Properties

    private let leftLine = UIView()
    private let label = UILabel()
    private let rightLine = UIView()

    // MARK: - Initialization

    init(text: String = "o continuar con") {
        super.init(frame: .zero)
        setupUI(text: text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI(text: String) {
        prepareForAutoLayout()

        // Configurar label primero para poder referenciarlo
        label
            .addTo(self)
            .text(text)
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .centerInSuperview()

        // Configurar línea izquierda
        leftLine
            .addTo(self)
            .background(.separator)
            .height(1)
            .pinLeading()
            .centerY()
            .pinTrailing(to: label.leadingAnchor, constant: -Spacing.small)

        // Configurar línea derecha
        rightLine
            .addTo(self)
            .background(.separator)
            .height(1)
            .pinTrailing()
            .centerY()
            .pinLeading(to: label.trailingAnchor, constant: Spacing.small)
    }

    // MARK: - Public Methods

    /// Actualiza el texto del divider
    func updateText(_ text: String) {
        label.text = text
    }
}
