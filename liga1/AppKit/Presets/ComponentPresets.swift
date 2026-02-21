//
//  ComponentPresets.swift
//  liga1
//
//  Created by AppKit
//  Factories para crear componentes UI pre-configurados
//

import UIKit

// MARK: - Component Presets

public struct ComponentPresets {

    // MARK: - TextField Preset

    /// Configura un TextField con estilo estándar
    public static func styledTextField(
        placeholder: String,
        cornerRadius: CGFloat = 12,
        leftPadding: CGFloat = Spacing.standard
    ) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return textField
    }

    // MARK: - Button Presets

    /// Crea un botón primario con estilo estándar
    public static func primaryButton(
        title: String,
        backgroundColor: UIColor = .systemBlue,
        cornerRadius: CGFloat = 12,
        height: CGFloat = 52
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }

    /// Crea un botón secundario con borde
    public static func secondaryButton(
        title: String,
        borderColor: UIColor = .separator,
        cornerRadius: CGFloat = 12,
        height: CGFloat = 52
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }

    /// Crea un botón de Google Sign In con logo y texto
    public static func googleSignInButton(
        title: String = "Continuar con Google",
        logoImageName: String = "g-logo",
        cornerRadius: CGFloat = 12,
        height: CGFloat = 52
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.prepareForAutoLayout()
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.heightAnchor.constraint(equalToConstant: height).isActive = true

        let logoImageView = UIImageView(image: UIImage(named: logoImageName))
            .contentMode(.scaleAspectFit)
            .square(32)

        let label = UILabel()
            .text(title)
            .font(.systemFont(ofSize: 17, weight: .medium))
            .textColor(.label)

        logoImageView.addTo(button)
            .pinLeading(constant: Spacing.standard)
            .centerY()

        label.addTo(button)
            .centerX()
            .centerY()

        return button
    }

    // MARK: - Label Presets

    /// Crea un label de título
    public static func titleLabel(
        text: String? = nil,
        fontSize: CGFloat = 24,
        weight: UIFont.Weight = .bold
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Crea un label de subtítulo
    public static func subtitleLabel(
        text: String? = nil,
        fontSize: CGFloat = 16,
        weight: UIFont.Weight = .regular
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Crea un label para empty state
    public static func emptyStateLabel(
        text: String,
        fontSize: CGFloat = 16
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }

    // MARK: - ImageView Preset

    /// Crea un ImageView con aspecto y tinte
    public static func imageView(
        image: UIImage? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        tintColor: UIColor? = nil
    ) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let tintColor = tintColor {
            imageView.tintColor = tintColor
        }
        return imageView
    }

    // MARK: - Divider

    /// Crea un divider view con texto centrado entre dos líneas
    static func dividerView(text: String = "o continuar con") -> DividerView {
        return DividerView(text: text)
    }

    // MARK: - Loading Overlay

    /// Crea un overlay de carga
    public static func loadingOverlay(
        in superview: UIView,
        activityIndicatorColor: UIColor = .systemBlue
    ) -> (overlay: UIView, indicator: UIActivityIndicatorView) {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = activityIndicatorColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        superview.addSubview(overlay)
        overlay.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: superview.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: superview.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])

        return (overlay, activityIndicator)
    }
}
