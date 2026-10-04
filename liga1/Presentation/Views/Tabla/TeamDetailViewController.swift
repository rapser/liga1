//
//  TeamDetailViewController.swift
//  liga1
//

import UIKit
import Combine

/// Ficha de un equipo: escudo, datos del club y plantilla agrupada por línea.
final class TeamDetailViewController: UIViewController {

    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerView = UIView()
    private let logoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let creditLabel = UILabel()

    // MARK: - Properties

    private let viewModel: TeamDetailViewModel
    private var sections: [TeamDetailViewModel.SquadSection] = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: TeamDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = viewModel.team.nombre
        navigationItem.largeTitleDisplayMode = .never

        setupTableView()
        setupHeader()
        setupStatusViews()
        bindViewModel()
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .appBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        tableView.allowsSelection = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupHeader() {
        logoImageView.image = UIImage(named: viewModel.team.logo)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = viewModel.team.nombre
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0

        subtitleLabel.text = [viewModel.team.ciudad, viewModel.team.estadio]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [logoImageView, nameLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        stack.setCustomSpacing(12, after: logoImageView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(stack)

        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 84),
            stack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Spacing.standard),
            stack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Spacing.standard)
        ])
        tableView.tableHeaderView = headerView
    }

    private func setupStatusViews() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        creditLabel.font = .systemFont(ofSize: 12)
        creditLabel.textColor = .secondaryLabel
        creditLabel.textAlignment = .center
        creditLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 260),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.large),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.large),
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 260)
        ])
    }

    /// Un `tableHeaderView` con Auto Layout no se dimensiona solo: se mide y se reasigna.
    private func sizeHeaderToFit() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let size = headerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        guard headerView.frame.height != size.height || headerView.frame.width != width else { return }
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: size.height))
        tableView.tableHeaderView = headerView
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: TeamDetailViewModel.State) {
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        tableView.tableFooterView = nil

        switch state {
        case .loading:
            sections = []
            activityIndicator.startAnimating()
        case .loaded(let loaded):
            sections = loaded
            showCreditFooter()
        case .empty:
            sections = []
            showStatus("Aún no tenemos la plantilla de este equipo.")
        case .failed(let message):
            sections = []
            showStatus(message)
        }
        tableView.reloadData()
    }

    private func showStatus(_ message: String) {
        statusLabel.text = message
        statusLabel.isHidden = false
    }

    private func showCreditFooter() {
        guard let credit = viewModel.photoCredit else { return }
        creditLabel.text = "Fotos: \(credit)"
        creditLabel.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableFooterView = creditLabel
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TeamDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].players.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let current = sections[section]
        return "\(current.position.sectionTitle) (\(current.players.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerCell.reuseIdentifier, for: indexPath
        ) as? PlayerCell else {
            return UITableViewCell()
        }
        cell.configure(with: sections[indexPath.section].players[indexPath.row])
        return cell
    }
}
