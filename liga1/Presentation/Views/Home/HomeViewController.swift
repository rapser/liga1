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

    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: HomeViewModel = DIContainer.shared.makeHomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = DIContainer.shared.makeHomeViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchActiveJornadas()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        LayoutPresets.configureTableView(tableView, in: view, delegate: self, dataSource: self)
    }

    private func bindViewModel() {
        // Observar cambios en las secciones de jornadas
        viewModel.$jornadaSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Observar estado de carga
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                // TODO: Mostrar/ocultar indicador de carga
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
