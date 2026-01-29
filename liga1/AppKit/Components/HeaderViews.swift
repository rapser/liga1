//
//  HeaderViews.swift
//  liga1
//
//  Created by AppKit
//

import UIKit

// MARK: - SectionHeaderView (Base Class)

/// Vista base para headers de secciones
class SectionHeaderView: UIView {

    // MARK: - Properties

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    private lazy var stackView = UIStackView.vStack(spacing: Spacing.tiny) { [titleLabel, subtitleLabel] }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        stackView
            .addTo(self)
            .fillSuperview(padding: UIEdgeInsets(top: Spacing.medium, left: Spacing.standard, bottom: Spacing.medium, right: Spacing.standard))

        titleLabel
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.label)
            .lines(1)

        subtitleLabel
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .lines(1)
            .hidden(true)
    }

    // MARK: - Configuration

    func configure(title: String, subtitle: String? = nil) {
        titleLabel.text = title

        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.hidden(false)
        } else {
            subtitleLabel.hidden(true)
        }
    }
}

// MARK: - DateHeaderView

/// Header para mostrar la fecha (Hoy, Mañana, fecha específica)
class DateHeaderView: UIView {

    // MARK: - Properties

    private let dateLabel = UILabel()
    private let containerView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        containerView
            .addTo(self)
            .fillSuperview(padding: UIEdgeInsets(top: Spacing.standard, left: Spacing.standard, bottom: Spacing.small, right: Spacing.standard))

        dateLabel
            .addTo(containerView)
            .fillSuperview()
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.label)
            .alignment(.left)
            .lines(1)
    }

    // MARK: - Configuration

    func configure(with date: Date) {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            dateLabel.text = "Hoy"
        } else if calendar.isDateInTomorrow(date) {
            dateLabel.text = "Mañana"
        } else if calendar.isDateInYesterday(date) {
            dateLabel.text = "Ayer"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "EEEE, d 'de' MMMM"
            dateLabel.text = formatter.string(from: date).capitalized
        }
    }

    func configure(with text: String) {
        dateLabel.text = text
    }
}

// MARK: - JornadaHeaderView

/// Header para mostrar Jornada + Torneo
class JornadaHeaderView: UIView {

    // MARK: - Properties

    private let jornadaLabel = UILabel()
    private let torneoLabel = UILabel()
    private lazy var stackView = UIStackView.vStack(spacing: Spacing.tiny) { [jornadaLabel, torneoLabel] }
    private let containerView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor.systemGray6

        containerView
            .addTo(self)
            .fillSuperview(padding: UIEdgeInsets(top: Spacing.medium, left: Spacing.standard, bottom: Spacing.medium, right: Spacing.standard))

        stackView
            .addTo(containerView)
            .fillSuperview()

        jornadaLabel
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.label)
            .alignment(.center)
            .lines(1)

        torneoLabel
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .alignment(.center)
            .lines(1)
    }

    // MARK: - Configuration

    func configure(jornada: String, torneo: String) {
        jornadaLabel.text = jornada
        torneoLabel.text = torneo
    }
}

// MARK: - TitleHeaderView

/// Header simple con solo un título (para vistas como Tabla de Posiciones)
class TitleHeaderView: UIView {

    // MARK: - Properties

    private let titleLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        titleLabel
            .addTo(self)
            .fillSuperview(padding: UIEdgeInsets(top: Spacing.standard, left: Spacing.standard, bottom: Spacing.medium, right: Spacing.standard))
            .font(.boldSystemFont(ofSize: 20))
            .textColor(.label)
            .alignment(.left)
            .lines(1)
    }

    // MARK: - Configuration

    func configure(title: String) {
        titleLabel.text = title
    }

    func configure(title: String, textAlignment: NSTextAlignment) {
        titleLabel.text = title
        titleLabel.alignment(textAlignment)
    }
}

// MARK: - EmptyStateView

/// Vista para mostrar cuando no hay datos
class EmptyStateView: UIView {

    // MARK: - Properties

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private lazy var stackView = UIStackView.vStack(spacing: Spacing.medium, alignment: .center) { [imageView, titleLabel, messageLabel] }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        stackView
            .addTo(self)
            .centerY()
            .pinLeading(constant: 40)
            .pinTrailing(constant: 40)

        imageView
            .contentMode(.scaleAspectFit)
            .tintColor(.systemGray3)
            .size(CGSize(width: 80, height: 80))

        titleLabel
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.label)
            .alignment(.center)
            .lines(0)

        messageLabel
            .font(.systemFont(ofSize: 15))
            .textColor(.secondaryLabel)
            .alignment(.center)
            .lines(0)
    }

    // MARK: - Configuration

    func configure(
        image: UIImage?,
        title: String,
        message: String
    ) {
        imageView.image = image
        imageView.hidden(image == nil)
        titleLabel.text = title
        messageLabel.text = message
    }

    func configure(
        systemImage: String,
        title: String,
        message: String
    ) {
        imageView.image = UIImage(systemName: systemImage)
        imageView.hidden(false)
        titleLabel.text = title
        messageLabel.text = message
    }

    /// Añade una vista adicional al estado vacío (p. ej. un botón de acción)
    func addCustomView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
}
