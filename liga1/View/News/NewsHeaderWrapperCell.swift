//
//  NewsHeaderWrapperCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

class NewsHeaderWrapperCell: UITableViewCell {
    private let headerView: NewsHeaderView

    init(item: NewsItem) {
        headerView = NewsHeaderView(item: item, sectionTitle: "")
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
