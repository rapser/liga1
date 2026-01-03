//
//  NewsHeaderView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher

class NewsHeaderView: UIView {

    private lazy var newsImageView = UIImageView()
        .prepareForAutoLayout()
        .contentMode(.scaleAspectFill)
        .clip()
        .corner(8)

    private lazy var titleLabel = UILabel()
        .prepareForAutoLayout()
        .font(.boldSystemFont(ofSize: 18))
        .lines(3)
        .textColor(.label)

    init(item: NewsItem, sectionTitle: String) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground

        // Cargar imagen
        if let url = URL(string: item.imageUrl) {
            newsImageView.kf.setImage(with: url)
        }

        // Configurar título
        titleLabel.text(item.title)

        // Layout
        newsImageView
            .addTo(self)
            .pinTop(constant: Spacing.small)
            .pinHorizontal(padding: Spacing.standard)
            .height(240)

        titleLabel
            .addTo(self)
            .pinTop(to: newsImageView.bottomAnchor, constant: Spacing.small)
            .pinHorizontal(padding: Spacing.standard)
            .pinBottom(constant: Spacing.standard)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
