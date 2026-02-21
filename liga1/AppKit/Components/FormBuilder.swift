//
//  FormBuilder.swift
//  liga1
//
//  Created by AppKit
//  Helper para construir formularios y pantallas de settings
//

import UIKit

// MARK: - FormSection

/// Sección de formulario que agrupa campos relacionados
class FormSection: UIView {

    // MARK: - Properties

    private let stackView: UIStackView
    private let titleLabel = UILabel()

    // MARK: - Initialization

    init(title: String? = nil, spacing: CGFloat = Spacing.medium) {
        stackView = UIStackView()
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        if let title = title {
            titleLabel
                .text(title)
                .font(AppTheme.headline)
                .textColor(.label)
                .lines(1)
            stackView.addArrangedSubview(titleLabel)
            stackView.setCustomSpacing(Spacing.small, after: titleLabel)
        }

        addSubview(stackView)
        stackView.fillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Form Fields

    /// Agrega un campo de texto con label
    @discardableResult
    func addTextField(
        label: String,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> UITextField {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = Spacing.tiny

        let fieldLabel = UILabel()
            .text(label)
            .font(AppTheme.subheadline)
            .textColor(.secondaryLabel)

        let textField = ComponentPresets.styledTextField(placeholder: placeholder)
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure

        container.addArrangedSubview(fieldLabel)
        container.addArrangedSubview(textField)
        stackView.addArrangedSubview(container)

        return textField
    }

    /// Agrega un switch con label
    @discardableResult
    func addSwitch(label: String, isOn: Bool = false) -> UISwitch {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let switchLabel = UILabel()
            .text(label)
            .font(AppTheme.body)
            .textColor(.label)

        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.translatesAutoresizingMaskIntoConstraints = false

        switchLabel.addTo(container)
            .pinLeading()
            .centerY()
            .pinTrailing(to: toggle.leadingAnchor, constant: Spacing.small)

        toggle.addTo(container)
            .pinTrailing()
            .centerY()

        container.heightAnchor.constraint(greaterThanOrEqualToConstant: AppTheme.Heights.cellMin).isActive = true

        stackView.addArrangedSubview(container)
        return toggle
    }

    /// Agrega un botón de acción
    @discardableResult
    func addButton(title: String, style: FormButtonStyle = .primary) -> UIButton {
        let button: UIButton
        switch style {
        case .primary:
            button = ComponentPresets.primaryButton(title: title)
        case .secondary:
            button = ComponentPresets.secondaryButton(title: title)
        case .destructive:
            button = ComponentPresets.primaryButton(title: title, backgroundColor: .appDestructive)
        }

        stackView.addArrangedSubview(button)
        return button
    }

    /// Agrega un separador
    @discardableResult
    func addSeparator(color: UIColor = .separator) -> Self {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = color
        separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        stackView.addArrangedSubview(separator)
        return self
    }

    /// Agrega un label informativo
    @discardableResult
    func addInfoLabel(text: String) -> UILabel {
        let label = UILabel()
            .text(text)
            .font(AppTheme.footnote)
            .textColor(.secondaryLabel)
            .lines(0)
        stackView.addArrangedSubview(label)
        return label
    }

    /// Agrega una vista personalizada
    @discardableResult
    func addCustomView(_ view: UIView) -> Self {
        stackView.addArrangedSubview(view)
        return self
    }
}

// MARK: - Form Button Style

enum FormButtonStyle {
    case primary
    case secondary
    case destructive
}
