//
//  NewsCell.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher

class NewsCell: UITableViewCell {

    private let newsImageView = UIImageView()
    private let titleLabel = UILabel()
    private let fechaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        // Imagen
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.layer.cornerRadius = 4
        newsImageView.translatesAutoresizingMaskIntoConstraints = false

        // Título
        titleLabel.font = .boldSystemFont(ofSize: 12)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Fecha
        fechaLabel.font = .systemFont(ofSize: 10)
        fechaLabel.textColor = .gray
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(newsImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(fechaLabel)

        NSLayoutConstraint.activate([
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsImageView.widthAnchor.constraint(equalToConstant: 120),
            newsImageView.heightAnchor.constraint(equalToConstant: 70),
            newsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            fechaLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            fechaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            fechaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fechaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with item: NewsItem) {
        titleLabel.text = item.title
        if let url = URL(string: item.imageUrl) {
            newsImageView.kf.setImage(with: url)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        fechaLabel.text = formatter.string(from: item.fecha)

        if item.destacada {
            contentView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.8, alpha: 1)
        } else {
            contentView.backgroundColor = .systemBackground
        }
    }
}

