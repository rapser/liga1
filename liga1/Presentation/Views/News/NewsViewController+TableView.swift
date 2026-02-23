//
//  NewsViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit
import SafariServices

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sortedCategories.count
    }

    // MARK: - Rows

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoria = viewModel.sortedCategories[section]
        let count = viewModel.groupedNews[categoria]?.count ?? 0
        return count + 1 // fila 0 = cabecera de categoría, filas 1..n = noticias
    }

    // MARK: - Cells

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoria = viewModel.sortedCategories[indexPath.section]

        // Fila 0: cabecera de categoría como celda
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CategoryHeaderCell.reuseIdentifier,
                for: indexPath
            ) as? CategoryHeaderCell else {
                return UITableViewCell()
            }
            cell.configure(with: categoria)
            return cell
        }

        // Filas 1..n: contenido de noticias
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row - 1] else {
            return UITableViewCell()
        }

        if newsItem.featured {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FeaturedNewsContentCell.reuseIdentifier,
                for: indexPath
            ) as? FeaturedNewsContentCell else {
                return UITableViewCell()
            }
            cell.configure(with: newsItem)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NewsCell.reuseIdentifier,
                for: indexPath
            ) as? NewsCell else {
                return UITableViewCell()
            }
            cell.configure(with: newsItem)
            return cell
        }
    }

    // MARK: - Heights

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        let categoria = viewModel.sortedCategories[indexPath.section]
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row - 1] else {
            return 90
        }
        return newsItem.featured ? UITableView.automaticDimension : 90
    }

    // MARK: - Section Headers (desactivados — se usan celdas en su lugar)

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    // MARK: - Selection

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row > 0 else { return } // la cabecera no es seleccionable

        let categoria = viewModel.sortedCategories[indexPath.section]
        guard let newsItem = viewModel.groupedNews[categoria]?[indexPath.row - 1] else { return }

        if let url = URL(string: newsItem.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}
