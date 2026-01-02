//
//  NewsHeaderWrapperCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

// MARK: - Header para "NOTICIA DESTACADA"
class FeaturedNewsTitleHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "FeaturedNewsTitleHeaderView"

    private lazy var label = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 12, weight: .semibold))
        .text("NOTICIA DESTACADA")
        .textColor(.secondaryLabel)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground

        label
            .addTo(contentView)
            .pinHorizontal(padding: Spacing.standard)
            .pinTop(constant: Spacing.medium)
            .pinBottom(constant: Spacing.small)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Celda para noticia destacada (imagen + título)
class FeaturedNewsContentCell: UITableViewCell {
    static let reuseIdentifier = "FeaturedNewsContentCell"

    private var newsHeaderView: NewsHeaderView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
    }

    func configure(with item: NewsItem) {
        // Remover vista anterior si existe
        newsHeaderView?.removeFromSuperview()

        // Crear nueva vista
        let headerView = NewsHeaderView(item: item, sectionTitle: "")
        headerView
            .prepareForAutoLayout()
            .addTo(contentView)
            .fillSuperview()

        self.newsHeaderView = headerView
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Header para categorías (Liga 1, etc)
class CategoryHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "CategoryHeaderView"

    private lazy var label = UILabel()
        .prepareForAutoLayout()
        .font(.systemFont(ofSize: 12, weight: .semibold))
        .textColor(.secondaryLabel)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground

        label
            .addTo(contentView)
            .pinHorizontal(padding: Spacing.standard)
            .pinTop(constant: Spacing.medium)
            .pinBottom(constant: Spacing.small)
    }

    func configure(with title: String) {
        label.text = title.uppercased()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
