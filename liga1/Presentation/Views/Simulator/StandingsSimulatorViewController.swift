//
//  StandingsSimulatorViewController.swift
//  liga1
//

import UIKit
import Combine

final class StandingsSimulatorViewController: UIViewController {

    private let viewModel: StandingsSimulatorViewModel
    private var cancellables = Set<AnyCancellable>()
    private let initialTorneo: TorneoType

    private let torneos: [TorneoType] = [.apertura, .clausura, .acumulado]
    private lazy var selector = UISegmentedControl(items: torneos.map(\.displayName))
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(viewModel: StandingsSimulatorViewModel, torneo: TorneoType) {
        self.viewModel = viewModel
        self.initialTorneo = torneo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no soportado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Simulador"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            primaryAction: UIAction { [weak self] _ in self?.share() }
        )
        setupLayout()
        bind()

        let start = torneos.contains(initialTorneo) ? initialTorneo : .clausura
        selector.selectedSegmentIndex = torneos.firstIndex(of: start) ?? 1
        viewModel.send(.load(start))
    }

    // MARK: - Layout

    private func setupLayout() {
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.addAction(UIAction { [weak self] _ in
            guard let self, self.torneos.indices.contains(self.selector.selectedSegmentIndex) else { return }
            self.viewModel.send(.load(self.torneos[self.selector.selectedSegmentIndex]))
        }, for: .valueChanged)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 14

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true

        view.addSubview(selector)
        view.addSubview(scrollView)
        view.addSubview(spinner)
        scrollView.addSubview(contentStack)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            selector.topAnchor.constraint(equalTo: g.topAnchor, constant: 12),
            selector.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            selector.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: selector.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Binding

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: StandingsSimulatorViewModel.State) {
        state.isLoading ? spinner.startAnimating() : spinner.stopAnimating()

        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !state.isLoading else { return }

        if let error = state.error {
            contentStack.addArrangedSubview(messageLabel("No se pudo cargar el simulador.\n\(error)"))
            return
        }

        contentStack.addArrangedSubview(messageLabel(
            "Los cupos a copas y el descenso son referenciales: dependen de campeones de torneo y desempates."
        ))

        // Partidos restantes
        if state.fixtures.isEmpty {
            contentStack.addArrangedSubview(messageLabel("No hay partidos pendientes en este torneo."))
        } else {
            contentStack.addArrangedSubview(sectionHeader("PARTIDOS RESTANTES", actionTitle: "Reiniciar") { [weak self] in
                self?.viewModel.send(.resetScores)
            })
            for group in viewModel.groupedFixtures {
                contentStack.addArrangedSubview(subHeader("Fecha \(group.jornada)"))
                for fixture in group.fixtures {
                    contentStack.addArrangedSubview(fixtureRow(fixture))
                }
            }
        }

        // Tabla proyectada
        if !state.projected.isEmpty {
            contentStack.addArrangedSubview(sectionHeader("TABLA PROYECTADA", actionTitle: nil, action: nil))
            for row in state.projected {
                contentStack.addArrangedSubview(projectedRow(row))
            }
            contentStack.addArrangedSubview(zoneLegend())
        }
    }

    // MARK: - Componentes

    private func messageLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.text = text
        return l
    }

    private func sectionHeader(_ title: String, actionTitle: String?, action: (() -> Void)?) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .firstBaseline

        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        l.text = title
        row.addArrangedSubview(l)

        if let actionTitle, let action {
            let b = UIButton(configuration: .plain())
            b.configuration?.title = actionTitle
            b.configuration?.contentInsets = .zero
            b.setContentHuggingPriority(.required, for: .horizontal)
            b.addAction(UIAction { _ in action() }, for: .touchUpInside)
            row.addArrangedSubview(UIView()) // spacer
            row.addArrangedSubview(b)
        }
        return row
    }

    private func subHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .label
        l.text = text
        return l
    }

    private func fixtureRow(_ fixture: StandingsSimulatorViewModel.Fixture) -> UIView {
        let home = UILabel()
        home.font = .systemFont(ofSize: 13)
        home.textColor = .label
        home.textAlignment = .right
        home.numberOfLines = 1
        home.adjustsFontSizeToFitWidth = true
        home.minimumScaleFactor = 0.8
        home.text = fixture.homeName

        let away = UILabel()
        away.font = .systemFont(ofSize: 13)
        away.textColor = .label
        away.numberOfLines = 1
        away.adjustsFontSizeToFitWidth = true
        away.minimumScaleFactor = 0.8
        away.text = fixture.awayName

        let score = UILabel()
        score.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        score.textColor = .label
        score.textAlignment = .center
        score.text = "\(fixture.homeGoals) - \(fixture.awayGoals)"
        score.widthAnchor.constraint(equalToConstant: 52).isActive = true

        let id = fixture.id
        let dec = stepButton("minus") { [weak self] in self?.bump(id, homeDelta: -1) }
        let inc = stepButton("plus") { [weak self] in self?.bump(id, homeDelta: +1) }
        let decA = stepButton("minus") { [weak self] in self?.bump(id, awayDelta: -1) }
        let incA = stepButton("plus") { [weak self] in self?.bump(id, awayDelta: +1) }

        let row = UIStackView(arrangedSubviews: [home, dec, inc, score, decA, incA, away])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        home.setContentHuggingPriority(.defaultLow, for: .horizontal)
        away.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    private func stepButton(_ symbol: String, _ action: @escaping () -> Void) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.image = UIImage(systemName: symbol)
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
        let b = UIButton(configuration: config)
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        b.setContentHuggingPriority(.required, for: .horizontal)
        return b
    }

    private func bump(_ id: String, homeDelta: Int = 0, awayDelta: Int = 0) {
        guard let f = viewModel.state.fixtures.first(where: { $0.id == id }) else { return }
        viewModel.send(.setScore(id: id, home: f.homeGoals + homeDelta, away: f.awayGoals + awayDelta))
    }

    private func projectedRow(_ row: StandingsSimulatorViewModel.ProjectedRow) -> UIView {
        let bar = UIView()
        bar.backgroundColor = color(for: row.zone)
        bar.layer.cornerRadius = 2
        bar.widthAnchor.constraint(equalToConstant: 4).isActive = true

        let pos = UILabel()
        pos.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        pos.textColor = .secondaryLabel
        pos.text = "\(row.pos)"
        pos.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let name = UILabel()
        name.font = .systemFont(ofSize: 14)
        name.textColor = .label
        name.text = row.name
        name.numberOfLines = 1
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.8

        let delta = UILabel()
        delta.font = .systemFont(ofSize: 11, weight: .semibold)
        delta.widthAnchor.constraint(equalToConstant: 34).isActive = true
        if row.deltaVsBase > 0 {
            delta.text = "▲\(row.deltaVsBase)"
            delta.textColor = .systemGreen
        } else if row.deltaVsBase < 0 {
            delta.text = "▼\(-row.deltaVsBase)"
            delta.textColor = .systemRed
        } else {
            delta.text = ""
        }

        let stats = UILabel()
        stats.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        stats.textColor = .secondaryLabel
        stats.textAlignment = .right
        stats.text = "PJ \(row.pj)   DG \(signed(row.dg))"

        let pts = UILabel()
        pts.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        pts.textColor = .label
        pts.textAlignment = .right
        pts.text = "\(row.pts)"
        pts.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let rowStack = UIStackView(arrangedSubviews: [bar, pos, name, delta, stats, pts])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 8
        name.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bar.heightAnchor.constraint(equalTo: rowStack.heightAnchor, multiplier: 0.7).isActive = true
        return rowStack
    }

    private func zoneLegend() -> UIView {
        let items: [(QualificationZone, String)] = [
            (.libertadores, "Libertadores (grupos)"),
            (.libertadoresPrevia, "Libertadores (previa)"),
            (.sudamericana, "Sudamericana"),
            (.descenso, "Descenso")
        ]
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        for (zone, text) in items {
            let dot = UIView()
            dot.backgroundColor = color(for: zone)
            dot.layer.cornerRadius = 3
            dot.widthAnchor.constraint(equalToConstant: 12).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 12).isActive = true
            let l = UILabel()
            l.font = .systemFont(ofSize: 12)
            l.textColor = .label
            l.text = text
            let r = UIStackView(arrangedSubviews: [dot, l])
            r.axis = .horizontal
            r.alignment = .center
            r.spacing = 8
            stack.addArrangedSubview(r)
        }
        return stack
    }

    private func color(for zone: QualificationZone) -> UIColor {
        switch zone {
        case .libertadores: return .libertadoresGold
        case .libertadoresPrevia: return .libertadoresLightGold
        case .sudamericana: return .sudamericanaBlue
        case .descenso: return .relegationRed
        case .none: return .clear
        }
    }

    private func signed(_ n: Int) -> String { n > 0 ? "+\(n)" : "\(n)" }

    // MARK: - Compartir

    private func share() {
        let state = viewModel.state
        guard !state.projected.isEmpty else { return }

        let card = makeShareCard(state)
        let image = ShareImageRenderer.image(of: card, size: ShareImageRenderer.storySize)
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activity, animated: true)
    }

    private func makeShareCard(_ state: StandingsSimulatorViewModel.State) -> UIView {
        let card = UIView(frame: CGRect(origin: .zero, size: ShareImageRenderer.storySize))
        card.backgroundColor = .systemBackground

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 56, weight: .bold)
        title.textColor = .label
        title.numberOfLines = 2
        title.text = "Mi tabla proyectada\n\(state.torneo.displayName) · Liga 1"

        let rows = UIStackView()
        rows.translatesAutoresizingMaskIntoConstraints = false
        rows.axis = .vertical
        rows.spacing = 18

        for row in state.projected {
            let bar = UIView()
            bar.backgroundColor = color(for: row.zone)
            bar.widthAnchor.constraint(equalToConstant: 10).isActive = true

            let pos = UILabel()
            pos.font = .monospacedDigitSystemFont(ofSize: 34, weight: .medium)
            pos.textColor = .secondaryLabel
            pos.text = "\(row.pos)"
            pos.widthAnchor.constraint(equalToConstant: 60).isActive = true

            let name = UILabel()
            name.font = .systemFont(ofSize: 34)
            name.textColor = .label
            name.text = row.name

            let pts = UILabel()
            pts.font = .monospacedDigitSystemFont(ofSize: 34, weight: .bold)
            pts.textColor = .label
            pts.text = "\(row.pts)"

            let r = UIStackView(arrangedSubviews: [bar, pos, name, UIView(), pts])
            r.axis = .horizontal
            r.alignment = .center
            r.spacing = 16
            bar.heightAnchor.constraint(equalToConstant: 44).isActive = true
            rows.addArrangedSubview(r)
        }

        card.addSubview(title)
        card.addSubview(rows)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 90),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 70),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -70),
            rows.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 60),
            rows.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 70),
            rows.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -70)
        ])
        return card
    }
}
