//
//  NewsHeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher

class NewsHeaderView: UIView {

    private let sectionLabel = UILabel()
    private let newsImageView = UIImageView()
    private let titleLabel = UILabel()
    private let categoriaLabel = UILabel()
    private let fechaLabel = UILabel()

    init(item: NewsItem, sectionTitle: String) {
        super.init(frame: .zero)

        // Imagen
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        if let url = URL(string: item.imageUrl) {
            newsImageView.kf.setImage(with: url)
        }

        // Fondo para destacar
        if item.destacada {
            backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.8, alpha: 1)
        }

        // Sección
        sectionLabel.font = .boldSystemFont(ofSize: 14)
        sectionLabel.text = sectionTitle
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Título
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 3
        titleLabel.text = item.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Categoría
        categoriaLabel.font = .boldSystemFont(ofSize: 14)
        categoriaLabel.text = item.categoria
        categoriaLabel.translatesAutoresizingMaskIntoConstraints = false

        // Fecha
        fechaLabel.font = .systemFont(ofSize: 12)
        fechaLabel.textColor = .gray
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        fechaLabel.text = formatter.string(from: item.fecha)
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(newsImageView)
        addSubview(sectionLabel)
        addSubview(titleLabel)
        addSubview(categoriaLabel)
        addSubview(fechaLabel)

        NSLayoutConstraint.activate([
            // Imagen ocupa todo el top y ancho
            newsImageView.topAnchor.constraint(equalTo: topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Sección y títulos debajo de la imagen
            sectionLabel.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 8),
            sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            categoriaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            categoriaLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            fechaLabel.centerYAnchor.constraint(equalTo: categoriaLabel.centerYAnchor),
            fechaLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fechaLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
