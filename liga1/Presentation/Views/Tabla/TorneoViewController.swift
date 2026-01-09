//
//  ViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import Combine

class TorneoViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["Apertura", "Clausura", "Acumulado"])
    let viewModel: TorneoViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: TorneoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSegmentedControl()
        configureTableView()
        bindViewModel()
        loadInitialData()
    }

    // MARK: - Private methods

    private func loadInitialData() {
        segmentedControl.selectedSegmentIndex = 0
        viewModel.loadTeams(for: .apertura)
    }

    private func bindViewModel() {
        viewModel.$displayedTeams
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

    private func configureSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        LayoutPresets.configureSegmentedControl(segmentedControl, in: view)
    }

    private func configureTableView() {
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        LayoutPresets.configureTableViewBelow(
            tableView,
            topView: segmentedControl,
            in: view,
            delegate: self,
            dataSource: self
        )
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.loadTeams(for: .apertura)
        case 1:
            viewModel.loadTeams(for: .clausura)
        case 2:
            viewModel.loadTeams(for: .acumulado)
        default:
            break
        }
    }
}
