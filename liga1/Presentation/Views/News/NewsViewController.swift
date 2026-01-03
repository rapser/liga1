//
//  NewsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Combine

class NewsViewController: UIViewController {

    let viewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Initialization

    init(viewModel: NewsViewModel = DIContainer.shared.makeNewsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = DIContainer.shared.makeNewsViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Noticias"

        setupTableView()
        bindViewModel()
        viewModel.fetchNews()
    }

    private func setupTableView() {
        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.register(FeaturedNewsContentCell.self, forCellReuseIdentifier: FeaturedNewsContentCell.reuseIdentifier)
        tableView.register(FeaturedNewsTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: FeaturedNewsTitleHeaderView.reuseIdentifier)
        tableView.register(CategoryHeaderView.self, forHeaderFooterViewReuseIdentifier: CategoryHeaderView.reuseIdentifier)
        tableView.estimatedSectionHeaderHeight = 40
        tableView.sectionHeaderHeight = UITableView.automaticDimension

        LayoutPresets.configureTableView(tableView, in: view, delegate: self, dataSource: self)
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
}
