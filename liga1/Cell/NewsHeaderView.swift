//
//  NewsHeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher

class NewsHeaderView: UIView {

    private let newsImageView = UIImageView()
    private let titleLabel = UILabel()

    init(item: NewsItem, sectionTitle: String) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground

        // Imagen con padding de 16 a los lados
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.layer.cornerRadius = 8
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        if let url = URL(string: item.imageUrl) {
            newsImageView.kf.setImage(with: url)
        }

        // Título con máximo 3 líneas y padding 16
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 3
        titleLabel.text = item.title
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(newsImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // Imagen con padding 16 izquierda/derecha desde arriba
            newsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            newsImageView.heightAnchor.constraint(equalToConstant: 240),

            // Título con padding 16 y máximo 3 líneas
            titleLabel.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
