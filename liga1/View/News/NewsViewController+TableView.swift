//
//  NewsViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit
import SafariServices

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + groupedNews.keys.count // sección destacada + categorías
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return featuredNews.isEmpty ? 0 : 1
        } else {
            let categorias = Array(groupedNews.keys)
            let categoria = categorias[section - 1]
            return groupedNews[categoria]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // No mostrar header para sección destacada (ya tiene su propio label integrado)
        if section == 0 {
            return nil
        }

        let container = UIView()
        container.backgroundColor = .white

        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])

        let categorias = Array(groupedNews.keys)
        let categoria = categorias[section - 1]
        label.text = categoria.uppercased()

        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0 // Sin header para sección destacada
        } else {
            return 40 // Altura para categorías (Liga 1, etc)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard let newsItem = featuredNews.first else { return UITableViewCell() }
            let cell = NewsHeaderWrapperCell(item: newsItem)
            return cell
        } else {
            let categorias = Array(groupedNews.keys)
            let categoria = categorias[indexPath.section - 1]
            guard let newsItem = groupedNews[categoria]?[indexPath.row] else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            cell.configure(with: newsItem)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let newsItem: NewsItem
        if indexPath.section == 0 {
            guard let item = featuredNews.first else { return }
            newsItem = item
        } else {
            let categorias = Array(groupedNews.keys)
            let categoria = categorias[indexPath.section - 1]
            guard let item = groupedNews[categoria]?[indexPath.row] else { return }
            newsItem = item
        }

        if let url = URL(string: newsItem.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 380 // NewsHeaderView
        } else {
            return 90 // NewsCell
        }
    }
}
