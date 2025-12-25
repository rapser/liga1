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
        // Sección 0: destacada (1 celda con imagen+título)
        // Sección 1+: categorías (con celdas)
        return 1 + groupedNews.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return featuredNews.isEmpty ? 0 : 1 // 1 celda para la noticia destacada
        }

        let categorias = Array(groupedNews.keys)
        let categoria = categorias[section - 1]
        return groupedNews[categoria]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Sección 0: Header "NOTICIA DESTACADA"
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeaturedNewsTitleHeaderView.reuseIdentifier) as! FeaturedNewsTitleHeaderView
            return header
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
        // Sección 0: celda de noticia destacada
        if indexPath.section == 0 {
            guard let featuredItem = featuredNews.first else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedNewsContentCell.reuseIdentifier, for: indexPath) as! FeaturedNewsContentCell
            cell.configure(with: featuredItem)
            return cell
        }

        // Otras secciones: celdas normales de noticias
        let categorias = Array(groupedNews.keys)
        let categoria = categorias[indexPath.section - 1]
        guard let newsItem = groupedNews[categoria]?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.configure(with: newsItem)
        return cell
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
            return UITableView.automaticDimension // FeaturedNewsContentCell con altura dinámica
        }
        return 90 // NewsCell height
    }
}
