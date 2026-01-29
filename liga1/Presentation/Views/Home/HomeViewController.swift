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
        title = "Inicio"
        setupUI()
        setupAdapter()
        bindViewModel()
        registerForTraitChanges()
        viewModel.fetchActiveJornadas()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Inicio"
        // Asegurar que el color esté actualizado cuando aparece la vista
        configureRefreshControlColor()
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

        // Configurar refresh control después de agregar el tableView
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Asegurar que el refresh control esté visible
        refreshControl.layer.zPosition = 1000

        configureRefreshControlColor()
    }
    
    private func configureRefreshControlColor() {
        // Configurar color del spinner según el modo (claro/oscuro)
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let color = isDarkMode ? UIColor.white : UIColor.systemBlue
        
        // En modo oscuro usar blanco para mejor visibilidad, en modo claro usar azul del sistema
        refreshControl.tintColor = color
        
        // Buscar y configurar el activity indicator en todas las subvistas del refresh control
        func findAndConfigureActivityIndicator(in view: UIView) {
            if let activityIndicator = view as? UIActivityIndicatorView {
                activityIndicator.color = color
                activityIndicator.style = .medium
                // Asegurar que esté en la parte superior
                activityIndicator.layer.zPosition = 1000
                activityIndicator.superview?.bringSubviewToFront(activityIndicator)
            }
            for subview in view.subviews {
                findAndConfigureActivityIndicator(in: subview)
            }
        }
        
        // Buscar en el refresh control y en el scroll view del tableView
        findAndConfigureActivityIndicator(in: refreshControl)
        if let scrollView = tableView.subviews.first(where: { $0 is UIScrollView }) {
            findAndConfigureActivityIndicator(in: scrollView)
        }
    }
    
    private func registerForTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (self: HomeViewController, previousTraitCollection: UITraitCollection) in
            self.configureRefreshControlColor()
        }
    }

    private func setupAdapter() {
        tableViewAdapter.delegate = self
    }

    @objc private func handleRefresh() {
        // Asegurar que el color esté actualizado cuando se activa el refresh
        configureRefreshControlColor()
        // Forzar actualización del color después de pequeños delays para que el refresh control esté visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.configureRefreshControlColor()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.configureRefreshControlColor()
        }
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
                if !isLoading {
                    self?.refreshControl.endRefreshing()
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
