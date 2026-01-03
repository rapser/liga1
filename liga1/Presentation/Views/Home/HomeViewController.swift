//
//  HomeViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()
    private lazy var tableViewAdapter = HomeTableViewAdapter(tableView: tableView)

    // MARK: - Initialization

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAdapter()
        bindViewModel()
        viewModel.fetchActiveJornadas()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Configurar refresh control
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Agregar tableView a la vista
        tableView.prepareForAutoLayout()
        tableView.addTo(view).fillSuperview()
    }

    private func setupAdapter() {
        tableViewAdapter.delegate = self
    }

    @objc private func handleRefresh() {
        viewModel.fetchActiveJornadas()
    }

    private func bindViewModel() {
        // Observar cambios en las secciones de jornadas
        viewModel.$jornadaSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.tableViewAdapter.update(with: sections)
            }
            .store(in: &cancellables)

        // Observar estado de carga
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        // Observar errores
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
}

// MARK: - HomeTableViewAdapterDelegate

extension HomeViewController: HomeTableViewAdapterDelegate {
    func didTapFavorite(matchId: String, in jornadaId: String) {
        viewModel.toggleFavorite(matchId: matchId)
    }
}
