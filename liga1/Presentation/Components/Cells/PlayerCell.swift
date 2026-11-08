//
//  PlayerCell.swift
//  liga1
//

import UIKit
import Kingfisher

/// Fila de la plantilla: foto (o ícono si no hay), nombre, edad y dorsal.
final class PlayerCell: UITableViewCell {

    static let reuseIdentifier = "PlayerCell"

    private static let avatarSize: CGFloat = 44
    /// Silueta de jugador: se ve si no hay URL, mientras carga y si la foto no se puede leer.
    private static let placeholder = UIImage(
        systemName: "person.fill",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    )

    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let numberLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.kf.cancelDownloadTask()
        showPlaceholder()
    }

    func configure(with player: Player) {
        nameLabel.text = player.name
        let country = [CountryFlag.emoji(for: player.nationality), CountryFlag.name(for: player.nationality)]
            .compactMap { $0 }
            .joined(separator: " ")
        // Ej. "🇵🇪 Perú · 25 años"
        let detail = [country.isEmpty ? nil : country, player.age.map { "\($0) años" }]
            .compactMap { $0 }
            .joined(separator: " · ")
        detailLabel.text = detail
        detailLabel.isHidden = detail.isEmpty
        numberLabel.text = player.number.map(String.init)

        loadPhoto(player.photoURL)

        accessibilityLabel = [
            player.number.map { "Dorsal \($0)" },
            player.name,
            CountryFlag.name(for: player.nationality),
            player.age.map { "\($0) años" }
        ]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    // MARK: - Foto

    /// Silueta centrada (sin recortar) sobre el fondo gris del círculo.
    private func showPlaceholder() {
        avatarView.contentMode = .center
        avatarView.image = Self.placeholder
    }

    /// Muestra la silueta y, solo si la foto se descarga bien, la reemplaza.
    /// Sin URL, con URL inválida o si la descarga falla, queda la silueta.
    private func loadPhoto(_ url: URL?) {
        showPlaceholder()
        guard let url else { return }

        let pixelSize = Self.avatarSize * UIScreen.main.scale
        avatarView.kf.setImage(
            with: url,
            placeholder: Self.placeholder,
            options: [
                // La foto de Transfermarkt pesa ~140 KB: se reduce al tamaño del avatar.
                .processor(DownsamplingImageProcessor(size: CGSize(width: pixelSize, height: pixelSize))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.2)),
                .onFailureImage(Self.placeholder)
            ]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.avatarView.contentMode = .scaleAspectFill
            case .failure(let error):
                // Una descarga cancelada por reutilizar la celda no debe tocar la nueva.
                guard !error.isTaskCancelled, !error.isNotCurrentTask else { return }
                self.showPlaceholder()
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        isAccessibilityElement = true

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = Self.avatarSize / 2
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.tintColor = .secondaryLabel
        showPlaceholder()

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label

        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel

        numberLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        numberLabel.textColor = .secondaryLabel
        numberLabel.textAlignment = .right
        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [avatarView, textStack, numberLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: Self.avatarSize),
            avatarView.heightAnchor.constraint(equalToConstant: Self.avatarSize),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
