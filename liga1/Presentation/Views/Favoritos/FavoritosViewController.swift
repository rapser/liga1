//
//  FavoritosViewController.swift
//  liga1
//
//  Created by miguel tomairo on 24/12/24.
//

import UIKit
import Combine

class FavoritosViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel: FavoritosViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var emptyStateLabel = LayoutPresets.emptyStateLabel(
        text: "No tienes partidos favoritos\nToca la estrella en un partido para agregarlo"
    )

    // MARK: - Initialization

    init(viewModel: FavoritosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favoritos"

        setupTableView()
        setupEmptyState()
        bindViewModel()
    }

    // MARK: - Setup UI
    private func setupTableView() {
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        LayoutPresets.configureTableView(tableView, in: view, delegate: self, dataSource: self)
    }

    private func setupEmptyState() {
        LayoutPresets.setupEmptyState(label: emptyStateLabel, in: view)
    }

    private func bindViewModel() {
        viewModel.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.tableView.reloadData()
                self?.updateEmptyState()
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

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !viewModel.matches.isEmpty
        tableView.isHidden = viewModel.matches.isEmpty
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritosViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchUI = viewModel.matches[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        let logoLocal = UIImage(named: matchUI.equipoLocalId ?? "shield.fill")
        let logoVisitante = UIImage(named: matchUI.equipoVisitanteId ?? "shield.fill")

        cell.delegate = self
        cell.configure(with: matchUI, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground

        let titleLabel = LayoutPresets.titleLabel(text: "Mis Partidos Favoritos", fontSize: 18)
        titleLabel
            .addTo(containerView)
            .pinLeading(constant: Spacing.standard)
            .pinTop(constant: Spacing.small)
            .pinBottom(constant: Spacing.small)

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.matches.isEmpty ? 0 : 50
    }
}

// MARK: - MatchTableViewCellDelegate
extension FavoritosViewController: MatchTableViewCellDelegate {
    func didTapFavorite(cell: MatchTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let matchUI = viewModel.matches[indexPath.row]

        viewModel.toggleFavorite(matchId: matchUI.id)
    }
}
