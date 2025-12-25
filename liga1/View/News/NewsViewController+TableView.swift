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
        // Sección 0: destacada (sin celdas, solo header)
        // Sección 1+: categorías (con celdas)
        return 1 + groupedNews.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0 // La destacada no tiene celdas, solo header
        }

        let categorias = Array(groupedNews.keys)
        let categoria = categorias[section - 1]
        return groupedNews[categoria]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Sección 0: Header con noticia destacada
        if section == 0 {
            if let featuredItem = featuredNews.first {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeaturedNewsHeaderView.reuseIdentifier) as! FeaturedNewsHeaderView
                header.configure(with: featuredItem)
                return header
            }
            return nil
        }

        // Otras secciones: Header de categoría (Liga 1, etc.)
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeaderView.reuseIdentifier) as! CategoryHeaderView
        let categorias = Array(groupedNews.keys)
        let categoria = categorias[section - 1]
        header.configure(with: categoria)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categorias = Array(groupedNews.keys)
        let categoria = categorias[indexPath.section - 1]
        guard let newsItem = groupedNews[categoria]?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.configure(with: newsItem)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let categorias = Array(groupedNews.keys)
        let categoria = categorias[indexPath.section - 1]
        guard let newsItem = groupedNews[categoria]?[indexPath.row] else { return }

        if let url = URL(string: newsItem.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // NewsCell height
    }
}
