//
//  NewsCell.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher

class NewsCell: UITableViewCell {

    static let reuseIdentifier = "NewsCell"

    private lazy var newsImageView = UIImageView()
        .prepareForAutoLayout()
        .contentMode(.scaleAspectFill)
        .clip()
        .corner(4)

    private lazy var titleLabel = UILabel()
        .prepareForAutoLayout()
        .font(.boldSystemFont(ofSize: 12))
        .lines(3)

    private lazy var fechaLabel = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 10))
        .textColor(.gray)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        // Imagen - centrada verticalmente, tamaño fijo
        newsImageView
            .addTo(contentView)
            .pinLeading(constant: Spacing.standard)
            .centerY()
            .size(width: 120, height: 70)

        // Título - parte superior
        titleLabel
            .addTo(contentView)
            .pinLeading(to: newsImageView.trailingAnchor, constant: Spacing.medium)
            .pinTrailing(constant: Spacing.standard)
            .pinTop(constant: Spacing.small)

        // Fecha - debajo del título
        fechaLabel
            .addTo(contentView)
            .pinLeading(to: newsImageView.trailingAnchor, constant: Spacing.medium)
            .pinTrailing(constant: Spacing.standard)
            .pinTop(to: titleLabel.bottomAnchor, constant: Spacing.tiny)

        // Bottom constraint con lessThanOrEqual
        fechaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Spacing.small).isActive = true
    }

    func configure(with item: NewsItemUI) {
        titleLabel.text = item.title
        if let url = item.imageURL {
            newsImageView.kf.setImage(with: url)
        }
        fechaLabel.text = item.fechaFormateada
        if item.category == .destacado {
            contentView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.8, alpha: 1)
        } else {
            contentView.backgroundColor = .systemBackground
        }
    }
}

