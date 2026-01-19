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
        // Solo secciones por categoría (ya no hay sección global de destacadas)
        return viewModel.sortedCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoria = viewModel.sortedCategories[section]
        return viewModel.groupedNews[categoria]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header de categoría (Liga 1, etc.)
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeaderView.reuseIdentifier) as? CategoryHeaderView else {
            return nil
        }
        let categoria = viewModel.sortedCategories[section]
        header.configure(with: categoria)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoria = viewModel.sortedCategories[indexPath.section]
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row] else {
            return UITableViewCell()
        }
        
        // Si es noticia destacada, usar FeaturedNewsContentCell
        if newsItem.featured {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedNewsContentCell.reuseIdentifier, for: indexPath) as? FeaturedNewsContentCell else {
                return UITableViewCell()
            }
            cell.configure(with: newsItem)
            return cell
        } else {
            // Noticia normal, usar NewsCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell else {
                return UITableViewCell()
            }
            cell.configure(with: newsItem)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let categoria = viewModel.sortedCategories[indexPath.section]
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row] else { return }

        if let url = URL(string: newsItem.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let categoria = viewModel.sortedCategories[indexPath.section]
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row] else {
            return 90
        }
        
        // Si es noticia destacada, altura dinámica
        if newsItem.featured {
            return UITableView.automaticDimension
        }
        // Noticia normal, altura fija
        return 90
    }
}
