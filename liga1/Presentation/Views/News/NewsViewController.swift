//
//  NewsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//  Refactored with AppKit on 2026-01-28
//

import UIKit
import Combine

class NewsViewController: UIViewController {

    // MARK: - UI Components
    private let containerView = ContainerView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Properties
    let viewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        bindViewModel()
        viewModel.fetchNews()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchNews()
    }

    // MARK: - Actions
    @objc private func appWillEnterForeground() {
        viewModel.fetchNews()
    }

    // MARK: - Setup Methods
    private func configureNavigationBar() {
        view.backgroundColor = .appBackground
        title = "Noticias"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupUI() {
        // Container principal
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // TableView
        setupTableView()
    }

    private func setupTableView() {
        tableView.prepareForAutoLayout()
        tableView.backgroundColor = .appBackground
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        tableView.register(FeaturedNewsContentCell.self, forCellReuseIdentifier: FeaturedNewsContentCell.reuseIdentifier)
        tableView.register(CategoryHeaderCell.self, forCellReuseIdentifier: CategoryHeaderCell.reuseIdentifier)
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self

        containerView.addSubview(tableView)
        tableView.fillSuperview()
    }

    // MARK: - Data & Binding
    private func bindViewModel() {
        viewModel.$groupedNews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$sortedCategories
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
