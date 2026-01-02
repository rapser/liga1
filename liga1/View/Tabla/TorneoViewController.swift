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
    let viewModel = TorneoViewModel()
    private var cancellables = Set<AnyCancellable>()

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
        segmentedControl.selectedSegmentIndex = 1
        viewModel.loadTeams(for: .clausura)
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
        view.addSubview(segmentedControl)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])

        let liga1RedColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = liga1RedColor
        segmentedControl.backgroundColor = .systemBackground

        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]

        segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)

        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }

    private func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        tableView.sectionHeaderTopPadding = 0

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
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
