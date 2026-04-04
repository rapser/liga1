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

    private let containerView = ContainerView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var tableViewAdapter = HomeTableViewAdapter(tableView: tableView)

    // Loader para la carga inicial
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.prepareForAutoLayout()
        indicator.hidesWhenStopped = true
        indicator.color = .label
        return indicator
    }()

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
        title = "Inicio"
        setupUI()
        setupAdapter()
        bindViewModel()
        viewModel.fetchActiveJornadas()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScoreUpdate), name: .scoreUpdateReceived, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Inicio"
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .appBackground
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // Configurar tableView para eliminar espacio entre header y nav bar
        // sectionHeaderTopPadding elimina el padding automático de iOS 15+
        tableView.sectionHeaderTopPadding = 0

        tableView
            .addTo(containerView)
            .fillSuperview()

        // Agregar loading indicator
        loadingIndicator
            .addTo(containerView)
            .centerInSuperview()
    }
    
    private func setupAdapter() {
        tableViewAdapter.delegate = self
    }

    @objc private func appWillEnterForeground() {
        viewModel.fetchActiveJornadas()
    }

    @objc private func handleScoreUpdate() {
        viewModel.fetchActiveJornadas()
    }

    private func bindViewModel() {
        viewModel.$jornadaSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.tableViewAdapter.update(with: sections)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if isLoading {
                    // Mostrar loader solo si la tabla está vacía (carga inicial)
                    if self.viewModel.jornadaSections.isEmpty {
                        self.loadingIndicator.startAnimating()
                        self.tableView.isHidden = true
                    }
                } else {
                    // Ocultar loader y mostrar tabla
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = false
                }
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

// MARK: - HomeTableViewAdapterDelegate

extension HomeViewController: HomeTableViewAdapterDelegate {
    func didTapFavorite(matchId: String, in jornadaId: String) {
        viewModel.toggleFavorite(matchId: matchId)
    }
}
