//
//  NewsHeaderWrapperCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

// MARK: - Header para noticia destacada
class FeaturedNewsHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "FeaturedNewsHeaderView"

    private var newsHeaderView: NewsHeaderView?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
    }

    func configure(with item: NewsItem) {
        // Remover vista anterior si existe
        newsHeaderView?.removeFromSuperview()

        // Crear nueva vista
        let headerView = NewsHeaderView(item: item, sectionTitle: "")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        self.newsHeaderView = headerView
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Header para categorías (Liga 1, etc)
class CategoryHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "CategoryHeaderView"

    private let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white

        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with title: String) {
        label.text = title.uppercased()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
