//
//  NewsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Combine

class NewsViewController: UIViewController {

    let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Noticias"

        setupTableView()
        bindViewModel()
        viewModel.fetchNews()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.register(FeaturedNewsContentCell.self, forCellReuseIdentifier: FeaturedNewsContentCell.reuseIdentifier)
        tableView.register(FeaturedNewsTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: FeaturedNewsTitleHeaderView.reuseIdentifier)
        tableView.register(CategoryHeaderView.self, forHeaderFooterViewReuseIdentifier: CategoryHeaderView.reuseIdentifier)
        tableView.estimatedSectionHeaderHeight = 40
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    private func bindViewModel() {
        viewModel.$featuredNews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$groupedNews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
