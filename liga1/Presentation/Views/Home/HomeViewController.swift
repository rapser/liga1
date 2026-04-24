//
//  HomeViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    private enum Liga1DisplayCalendar {
        static var lima: Calendar {
            var c = Calendar(identifier: .gregorian)
            c.timeZone = TimeZone(identifier: "America/Lima") ?? .current
            return c
        }
    }

    // MARK: - Properties

    private let containerView = ContainerView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: HomeViewModel
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private lazy var tableViewAdapter = HomeTableViewAdapter(tableView: tableView)
    private let emptyMatchesView = HomeEmptyMatchesPlaceholderView()
    /// Evita doble `refresh` en el primer ciclo (viewDidLoad ya carga); reduce parpadeos y cancelaciones.
    private var hasSkippedFirstWillAppearRefresh = false

    // Loader para la carga inicial
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.prepareForAutoLayout()
        indicator.hidesWhenStopped = true
        indicator.color = .label
        return indicator
    }()

    // MARK: - Initialization

    init(viewModel: HomeViewModel, container: DIContainer) {
        self.viewModel = viewModel
        self.container = container
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(calendarBarTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Elegir fecha de partidos"
        bindViewModel()
        tableViewAdapter.onMatchSelected = { [weak self] section, match in
            guard let self else { return }
            let ctx = MatchDetailContext(
                jornadaId: section.jornadaId,
                jornadaNumero: section.numero,
                torneo: section.torneo,
                match: match
            )
            let detail = self.container.makeMatchDetailViewController(context: ctx)
            self.navigationController?.pushViewController(detail, animated: true)
        }
        tableViewAdapter.onCalendarHeaderTapped = { [weak self] in
            self?.presentMatchDayPicker()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleScoreUpdate), name: .scoreUpdateReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Carga explícita al crear la pantalla: evita placeholder hasta el primer `viewWillAppear` si el fetch
        // quedaba invalidado por la carrera con `observe()`. `matchDayMode` ya es `.today` (hoy Perú).
        refreshContent(force: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Inicio"
        if !hasSkippedFirstWillAppearRefresh {
            hasSkippedFirstWillAppearRefresh = true
            return
        }
        refreshContent(force: true)
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

        emptyMatchesView.prepareForAutoLayout()
        emptyMatchesView.addTo(containerView).fillSuperview()
        emptyMatchesView.isHidden = true
        emptyMatchesView.onCalendarTapped = { [weak self] in
            self?.calendarBarTapped()
        }

        // Agregar loading indicator
        loadingIndicator
            .addTo(containerView)
            .centerInSuperview()
    }
    
    @objc private func handleScoreUpdate() {
        refreshContent(force: true)
    }

    @objc private func handleWillEnterForeground() {
        refreshContent(force: true)
    }

    @objc private func calendarBarTapped() {
        presentMatchDayPicker()
    }

    func refreshContent(force: Bool = false) {
        viewModel.fetchActiveJornadas(force: force)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func presentMatchDayPicker() {
        let cal = Liga1DisplayCalendar.lima
        let initial: Date
        switch viewModel.matchDayMode {
        case .today:
            initial = cal.startOfDay(for: Date())
        case .specificDay(let d):
            initial = cal.startOfDay(for: d)
        }

        let sheet = HomeCalendarDayListViewController(
            preselectedDay: initial,
            onPickDay: { [weak self] day in
                self?.viewModel.setMatchDayMode(.specificDay(day))
            },
            onResetToToday: { [weak self] in
                self?.viewModel.setMatchDayMode(.today)
            }
        )
        let nav = UINavigationController(rootViewController: sheet)
        nav.modalPresentationStyle = .pageSheet
        nav.navigationBar.prefersLargeTitles = false
        if let sheetPC = nav.sheetPresentationController {
            sheetPC.detents = [.large()]
            sheetPC.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    private func bindViewModel() {
        viewModel.$jornadaSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                guard let self else { return }
                self.tableViewAdapter.update(with: sections)
                self.applyHomeContentVisibility(isLoading: self.viewModel.isLoading)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                self.applyHomeContentVisibility(isLoading: isLoading)
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

    /// Tabla con partidos, placeholder alusivo o loader según estado.
    private func applyHomeContentVisibility(isLoading: Bool) {
        let empty = viewModel.jornadaSections.isEmpty

        if isLoading && empty {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyMatchesView.isHidden = true
        } else if isLoading && !empty {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            emptyMatchesView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            if empty {
                tableView.isHidden = true
                emptyMatchesView.isHidden = false
            } else {
                tableView.isHidden = false
                emptyMatchesView.isHidden = true
            }
        }
    }
}

// MARK: - Calendario lista nativa (±7 días, estilo oscuro tipo referencia)

private final class HomeCalendarDayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private enum Palette {
        static let sheetBackground = UIColor(red: 11 / 255, green: 22 / 255, blue: 33 / 255, alpha: 1)
        static let rowSelected = UIColor(red: 20 / 255, green: 40 / 255, blue: 61 / 255, alpha: 1)
        static let separator = UIColor.white.withAlphaComponent(0.12)
    }

    private static var limaCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/Lima") ?? .current
        return c
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let onPickDay: (Date) -> Void
    private let onResetToToday: () -> Void

    private let calendar = HomeCalendarDayListViewController.limaCalendar
    private var dayRange: [Date] = []
    private let todayStart: Date
    private var highlightedDay: Date

    init(preselectedDay: Date, onPickDay: @escaping (Date) -> Void, onResetToToday: @escaping () -> Void) {
        self.onPickDay = onPickDay
        self.onResetToToday = onResetToToday
        let cal = Self.limaCalendar
        let start = cal.startOfDay(for: Date())
        self.todayStart = start
        self.highlightedDay = cal.startOfDay(for: preselectedDay)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = Palette.sheetBackground
        title = "Calendario"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white

        buildDayRange()
        if !dayRange.contains(where: { calendar.startOfDay(for: $0) == highlightedDay }) {
            highlightedDay = todayStart
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Palette.sheetBackground
        tableView.separatorColor = Palette.separator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 52
        tableView.sectionHeaderTopPadding = 0
        tableView.register(CalendarDayPickerCell.self, forCellReuseIdentifier: CalendarDayPickerCell.reuseId)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.tableFooterView = makeFooter(width: view.bounds.width)

        if let idx = dayRange.firstIndex(where: { calendar.startOfDay(for: $0) == highlightedDay }) {
            let path = IndexPath(row: idx, section: 0)
            tableView.scrollToRow(at: path, at: .middle, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarDark()
        navigationController?.navigationBar.tintColor = .white
    }

    private func configureNavBarDark() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Palette.sheetBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func buildDayRange() {
        dayRange = (-7 ... 7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: todayStart)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let footer = tableView.tableFooterView else { return }
        let w = tableView.bounds.width
        if footer.frame.width != w {
            footer.frame = CGRect(x: 0, y: 0, width: w, height: footer.frame.height)
            tableView.tableFooterView = footer
        }
    }

    private func makeFooter(width: CGFloat) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: max(width, 320), height: 72))
        let button = UIButton(type: .system)
        button.setTitle("Volver a hoy", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let reset = self.onResetToToday
            self.dismiss(animated: true, completion: reset)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20)
        ])
        return container
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dayRange.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarDayPickerCell.reuseId, for: indexPath) as! CalendarDayPickerCell
        let day = dayRange[indexPath.row]
        let dayStart = calendar.startOfDay(for: day)
        let isToday = dayStart == todayStart
        let isHighlighted = dayStart == highlightedDay
        cell.configure(isToday: isToday, subtitleDate: day, isHighlighted: isHighlighted)
        cell.backgroundColor = isHighlighted ? Palette.rowSelected : Palette.sheetBackground
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let day = dayRange[indexPath.row]
        let start = calendar.startOfDay(for: day)
        let pick = onPickDay
        dismiss(animated: true) {
            pick(start)
        }
    }
}

private final class CalendarDayPickerCell: UITableViewCell {

    static let reuseId = "CalendarDayPickerCell"

    private let accentBar = UIView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        accentBar.translatesAutoresizingMaskIntoConstraints = false
        accentBar.backgroundColor = .white
        accentBar.isHidden = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)

        contentView.addSubview(accentBar)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            accentBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            accentBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            accentBar.widthAnchor.constraint(equalToConstant: 4),

            titleLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isToday: Bool, subtitleDate: Date, isHighlighted: Bool) {
        accentBar.isHidden = !isHighlighted

        if isToday {
            titleLabel.text = "HOY"
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        } else {
            let df = DateFormatter()
            df.locale = Locale(identifier: "es_PE")
            df.timeZone = TimeZone(identifier: "America/Lima") ?? .current
            df.dateFormat = "dd.MM."
            let dPart = df.string(from: subtitleDate)
            df.dateFormat = "EEEE"
            let wPart = df.string(from: subtitleDate).capitalized
            titleLabel.text = "\(dPart) \(wPart)"
            titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        }
    }
}
