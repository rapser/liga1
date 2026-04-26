//
//  HomeEmptyMatchesPlaceholderView.swift
//  liga1
//

import UIKit

/// Estado vacío cuando no hay partidos de Liga 1 para el día seleccionado.
final class HomeEmptyMatchesPlaceholderView: UIView {

    var onCalendarTapped: (() -> Void)?

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let taglineLabel = UILabel()
    private let calendarButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        iconView.image = UIImage(systemName: "soccerball")
            ?? UIImage(systemName: "sportscourt")
            ?? UIImage(systemName: "figure.soccer")
        iconView.tintColor = .liga1Red
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)

        let iconBackdrop = UIView()
        iconBackdrop.backgroundColor = .appSecondaryBackground
        iconBackdrop.layer.cornerRadius = 36
        iconBackdrop.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBackdrop.addSubview(iconView)

        titleLabel.text = "Sin partidos este día"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.text = "No hay encuentros de Liga 1 para la fecha que estás viendo. Elige otro día en el calendario y sigue cada jornada."
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        taglineLabel.text = "Liga 1 · El fútbol del Perú"
        taglineLabel.font = .systemFont(ofSize: 13, weight: .medium)
        taglineLabel.textColor = UIColor.liga1Red.withAlphaComponent(0.85)
        taglineLabel.textAlignment = .center
        taglineLabel.numberOfLines = 1

        var calConfig = UIButton.Configuration.filled()
        calConfig.title = "Abrir calendario"
        calConfig.baseForegroundColor = .white
        calConfig.baseBackgroundColor = .liga1Red
        calConfig.cornerStyle = .large
        calConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        calConfig.image = UIImage(systemName: "calendar")
        calConfig.imagePadding = 8
        calConfig.imagePlacement = .leading
        calendarButton.configuration = calConfig
        calendarButton.addAction(UIAction { [weak self] _ in
            self?.onCalendarTapped?()
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            iconBackdrop,
            titleLabel,
            messageLabel,
            taglineLabel,
            calendarButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.setCustomSpacing(20, after: iconBackdrop)
        stack.setCustomSpacing(10, after: messageLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: iconBackdrop.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackdrop.centerYAnchor),
            iconBackdrop.widthAnchor.constraint(equalToConstant: 96),
            iconBackdrop.heightAnchor.constraint(equalToConstant: 96),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -24),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -28)
        ])

        accessibilityElements = [titleLabel, messageLabel, calendarButton]
        titleLabel.accessibilityTraits.insert(.header)
        calendarButton.accessibilityHint = "Muestra el calendario para elegir otra fecha"
    }
}
