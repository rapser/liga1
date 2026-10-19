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
    private static let placeholder = UIImage(systemName: "person.fill")

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
        avatarView.image = Self.placeholder
    }

    func configure(with player: Player) {
        nameLabel.text = player.name
        detailLabel.text = player.age.map { "\($0) años" }
        detailLabel.isHidden = player.age == nil
        numberLabel.text = player.number.map(String.init)

        if let url = player.photoURL {
            avatarView.kf.setImage(with: url, placeholder: Self.placeholder)
        } else {
            avatarView.image = Self.placeholder
        }

        accessibilityLabel = [player.number.map { "Dorsal \($0)" }, player.name, player.age.map { "\($0) años" }]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        isAccessibilityElement = true

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = Self.avatarSize / 2
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.tintColor = .secondaryLabel
        avatarView.image = Self.placeholder

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
