//
//  MatchDetailViewController.swift
//  liga1
//

import UIKit
import Combine

final class MatchDetailViewController: UIViewController {

    private let viewModel: MatchDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    /// Contenedor de las secciones que dependen de datos remotos (Sabor Local +
    /// Información adicional). Se reconstruye al llegar `stadium` / `referee`.
    private let contextSectionsContainer: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = Spacing.medium
        return s
    }()

    private let segmentedControl: UISegmentedControl = {
        let c = UISegmentedControl(items: ["Resumen", "Estadísticas", "Alineaciones"])
        c.selectedSegmentIndex = 0
        c.selectedSegmentTintColor = .liga1Red
        c.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        c.setTitleTextAttributes([.foregroundColor: UIColor.liga1Red], for: .normal)
        return c
    }()

    private let contentContainer = UIView()
    private let resumenHost = MatchDetailScrollStackView()
    private let estadisticasHost = MatchDetailScrollStackView(scrollBackgroundColor: .appBackground)
    private let estadisticasPlaceholder = UIView()
    private let alineacionesPlaceholder = UIView()
    private let alineacionesHost = MatchDetailScrollStackView(
        scrollBackgroundColor: .appBackground,
        contentTopInset: 0,
        contentBottomInset: 0,
        contentHorizontalInset: Spacing.tiny
    )

    init(viewModel: MatchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        navigationItem.largeTitleDisplayMode = .never
        title = "Liga 1"

        let headphones = UIBarButtonItem(
            image: UIImage(systemName: "headphones"),
            style: .plain,
            target: self,
            action: #selector(headphonesTapped)
        )
        headphones.tintColor = .liga1Red

        let share = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )
        share.tintColor = .liga1Red
        navigationItem.rightBarButtonItems = [headphones, share]

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.prepareForAutoLayout()
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.small),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.standard),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.standard)
        ])

        contentContainer.prepareForAutoLayout()
        view.addSubview(contentContainer)
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: Spacing.medium),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setupResumen()
        setupPlaceholders()
        setupEstadisticasTab()
        setupAlineacionesTab()
        segmentChanged()
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.$stadium
            .combineLatest(viewModel.$referee, viewModel.$weather)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _ in self?.rebuildContextSections() }
            .store(in: &cancellables)

        // Termómetro Arbitral: cualquier cambio del estado de la encuesta reconstruye la sección.
        Publishers.CombineLatest4(
            viewModel.$refereePoll,
            viewModel.$pollTally,
            viewModel.$myPollVote,
            viewModel.$pollVoteInFlight
        )
        .combineLatest(viewModel.$pollVoteError)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _, _ in self?.rebuildContextSections() }
        .store(in: &cancellables)
    }

    private func setupResumen() {
        resumenHost.prepareForAutoLayout()
        contentContainer.addSubview(resumenHost)
        NSLayoutConstraint.activate([
            resumenHost.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            resumenHost.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            resumenHost.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            resumenHost.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        let stack = resumenHost.contentStack
        let vm = viewModel

        let comp = UILabel()
        comp.font = .systemFont(ofSize: 12, weight: .medium)
        comp.textColor = .secondaryLabel
        comp.textAlignment = .center
        comp.numberOfLines = 2
        comp.text = vm.competitionLine

        stack.addArrangedSubview(comp)
        stack.addArrangedSubview(makeScoreboardHeader())
        stack.addArrangedSubview(MatchDetailTitledSectionView.statRowsSection(title: "Estadísticas", rows: vm.resumenStatRows))
        stack.addArrangedSubview(makeTVSection())
        stack.addArrangedSubview(contextSectionsContainer)
        rebuildContextSections()
    }

    /// Reconstruye "Sabor Local" + "Información adicional" con lo que haya cargado el VM.
    private func rebuildContextSections() {
        contextSectionsContainer.arrangedSubviews.forEach {
            contextSectionsContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if viewModel.refereePollDisponible {
            contextSectionsContainer.addArrangedSubview(makeRefereePollSection())
        }
        if viewModel.saborLocalDisponible || viewModel.climaDisponible {
            contextSectionsContainer.addArrangedSubview(makeSaborLocalSection())
        }
        contextSectionsContainer.addArrangedSubview(makeInfoAdicionalSection())
    }

    // MARK: - Termómetro Arbitral (encuesta en vivo)

    private func makeRefereePollSection() -> UIView {
        let inner = UIStackView()
        inner.prepareForAutoLayout()
        inner.axis = .vertical
        inner.spacing = Spacing.small

        if let pregunta = viewModel.refereePollPregunta {
            let q = UILabel()
            q.font = .systemFont(ofSize: 14, weight: .semibold)
            q.textColor = .label
            q.numberOfLines = 0
            q.text = pregunta
            inner.addArrangedSubview(q)
        }

        let puedeVotar = viewModel.puedeVotarRefereePoll
        for opcion in viewModel.refereePollOpciones {
            inner.addArrangedSubview(
                puedeVotar ? pollVoteButton(for: opcion) : pollResultRow(for: opcion)
            )
        }

        let footer = UILabel()
        footer.font = .systemFont(ofSize: 12)
        footer.textColor = .secondaryLabel
        footer.text = "\(viewModel.refereePollEstadoDisplay) · \(viewModel.refereePollTotalDisplay)"
        inner.addArrangedSubview(footer)

        if let error = viewModel.pollVoteError {
            let e = UILabel()
            e.font = .systemFont(ofSize: 12)
            e.textColor = .systemRed
            e.numberOfLines = 0
            e.text = error
            inner.addArrangedSubview(e)
        }

        return MatchDetailTitledSectionView(title: "Termómetro Arbitral", uppercaseTitle: true, content: inner)
    }

    private func pollVoteButton(for opcion: MatchDetailViewModel.RefereePollOptionVM) -> UIView {
        var config = UIButton.Configuration.tinted()
        config.title = opcion.texto
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)

        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        button.isEnabled = !viewModel.pollVoteInFlight
        button.addAction(UIAction { [weak self] _ in
            self?.viewModel.voteRefereePoll(optionId: opcion.id)
        }, for: .touchUpInside)
        return button
    }

    private func pollResultRow(for opcion: MatchDetailViewModel.RefereePollOptionVM) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .firstBaseline

        let name = UILabel()
        name.font = .systemFont(ofSize: 14, weight: opcion.esMiVoto ? .semibold : .regular)
        name.textColor = .label
        name.text = opcion.esMiVoto ? "\(opcion.texto)  ✓" : opcion.texto

        let value = UILabel()
        value.font = .systemFont(ofSize: 13)
        value.textColor = .secondaryLabel
        value.textAlignment = .right
        value.text = "\(opcion.votos) · \(opcion.porcentaje)%"
        value.setContentHuggingPriority(.required, for: .horizontal)

        top.addArrangedSubview(name)
        top.addArrangedSubview(value)

        let track = UIView()
        track.backgroundColor = .secondarySystemFill
        track.layer.cornerRadius = 3
        track.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let fill = UIView()
        fill.backgroundColor = opcion.esMiVoto ? .tintColor : .tertiaryLabel
        fill.layer.cornerRadius = 3
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)
        NSLayoutConstraint.activate([
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor,
                                        multiplier: max(0.001, min(1.0, CGFloat(opcion.porcentaje) / 100)))
        ])

        container.addArrangedSubview(top)
        container.addArrangedSubview(track)
        return container
    }

    private func makeSaborLocalSection() -> UIView {
        let inner = UIStackView()
        inner.prepareForAutoLayout()
        inner.axis = .vertical
        inner.spacing = 0

        var rows: [UIView] = []
        if let factor = viewModel.factorGeograficoDisplay, let alt = viewModel.altitudDisplay {
            rows.append(infoRow(key: factor, value: alt))
        } else if let alt = viewModel.altitudDisplay {
            rows.append(infoRow(key: "Altitud", value: alt))
        }
        if let ciudad = viewModel.ciudadDisplay {
            rows.append(infoRow(key: "Ciudad", value: ciudad))
        }
        if let clima = viewModel.climaResumenDisplay {
            rows.append(infoRow(key: "Clima", value: clima))
        }
        if let sensacion = viewModel.climaSensacionDisplay {
            rows.append(infoRow(key: "Sensación térmica", value: sensacion))
        }
        if let viento = viewModel.climaVientoDisplay {
            rows.append(infoRow(key: "Viento", value: viento))
        }
        if let humedad = viewModel.climaHumedadDisplay {
            rows.append(infoRow(key: "Humedad", value: humedad))
        }
        if let precip = viewModel.climaPrecipitacionDisplay {
            rows.append(infoRow(key: "Prob. lluvia", value: precip))
        }

        for (index, row) in rows.enumerated() {
            if index > 0 { inner.addArrangedSubview(separatorLine()) }
            inner.addArrangedSubview(row)
        }

        if let dato = viewModel.datoHistorico {
            let l = UILabel()
            l.font = .systemFont(ofSize: 13)
            l.textColor = .secondaryLabel
            l.numberOfLines = 0
            l.text = dato
            if !rows.isEmpty { inner.addArrangedSubview(separatorLine()) }
            inner.setCustomSpacing(Spacing.small, after: inner.arrangedSubviews.last ?? l)
            inner.addArrangedSubview(l)
        }

        return MatchDetailTitledSectionView(title: "Sabor Local", uppercaseTitle: true, content: inner)
    }

    private func makeScoreboardHeader() -> UIView {
        let vm = viewModel
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        dateLabel.text = vm.dateTimeLine

        let statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.text = vm.statusLine
        statusLabel.textColor = vm.context.match.estado == .envivo ? .liga1Red : .label

        let scoreLabel = UILabel()
        scoreLabel.font = .systemFont(ofSize: 36, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .liga1Red
        scoreLabel.text = vm.scoreDisplay

        let leftStack = teamColumn(name: vm.localTeamName, assetId: vm.context.match.equipoLocalId)
        let rightStack = teamColumn(name: vm.visitTeamName, assetId: vm.context.match.equipoVisitanteId)

        let teamsRow = UIStackView(arrangedSubviews: [leftStack, scoreLabel, rightStack])
        teamsRow.axis = .horizontal
        teamsRow.alignment = .center
        teamsRow.distribution = .equalCentering
        teamsRow.spacing = 8

        let mainStack = UIStackView(arrangedSubviews: [dateLabel, teamsRow, statusLabel])
        mainStack.axis = .vertical
        mainStack.spacing = Spacing.small
        mainStack.prepareForAutoLayout()
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: Spacing.standard),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Spacing.standard),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Spacing.standard),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Spacing.standard),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])

        return container
    }

    private func teamColumn(name: String, assetId: String?) -> UIStackView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        if let id = assetId, let img = UIImage(named: id) {
            iv.image = img
            iv.tintColor = nil
        } else {
            iv.image = UIImage(systemName: "shield.fill")
        }
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 44),
            iv.heightAnchor.constraint(equalToConstant: 44)
        ])

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        let col = UIStackView(arrangedSubviews: [iv, nameLabel])
        col.axis = .vertical
        col.alignment = .center
        col.spacing = 6
        col.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return col
    }

    private func makeTVSection() -> UIView {
        let inner = UIStackView()
        inner.prepareForAutoLayout()
        inner.axis = .vertical
        inner.spacing = Spacing.small

        let channels = viewModel.tvChannels
        if channels.isEmpty {
            let l = UILabel()
            l.font = .systemFont(ofSize: 14)
            l.textColor = .secondaryLabel
            l.text = "Por confirmar"
            inner.addArrangedSubview(l)
        } else {
            let flow = UIStackView()
            flow.axis = .horizontal
            flow.spacing = 8
            flow.distribution = .fillProportionally
            for ch in channels {
                flow.addArrangedSubview(tvChip(ch))
            }
            inner.addArrangedSubview(flow)
        }

        return MatchDetailTitledSectionView(title: "Canal TV", uppercaseTitle: true, content: inner)
    }

    private func tvChip(_ text: String) -> UIView {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .label
        l.textAlignment = .center
        l.setContentHuggingPriority(.required, for: .horizontal)
        let wrap = UIView()
        wrap.backgroundColor = .secondarySystemBackground
        wrap.layer.cornerRadius = 8
        wrap.clipsToBounds = true
        l.prepareForAutoLayout()
        wrap.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            l.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 12),
            l.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8),
            l.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -12)
        ])
        return wrap
    }

    private func makeInfoAdicionalSection() -> UIView {
        let inner = UIStackView()
        inner.prepareForAutoLayout()
        inner.axis = .vertical
        inner.spacing = 0

        var rows: [UIView] = []
        if let nombreArbitro = viewModel.refereeNombreDisplay {
            let nacionalidad = viewModel.refereeNacionalidadDisplay
            rows.append(infoRow(key: "Árbitro",
                                value: nacionalidad.map { "\(nombreArbitro) · \($0)" } ?? nombreArbitro))
            if let penales = viewModel.refereePenalesPorPartidoDisplay {
                rows.append(infoRow(key: "Penales / partido", value: penales))
            }
            if let tarjetas = viewModel.refereeTarjetasPorPartidoDisplay {
                rows.append(infoRow(key: "Tarjetas / partido", value: tarjetas))
            }
        }
        rows.append(infoRow(key: "Estadio", value: viewModel.estadioDisplay))
        rows.append(infoRow(key: "Capacidad", value: viewModel.capacidadDisplay))

        for (index, row) in rows.enumerated() {
            if index > 0 { inner.addArrangedSubview(separatorLine()) }
            inner.addArrangedSubview(row)
        }

        return MatchDetailTitledSectionView(title: "Información adicional", uppercaseTitle: true, content: inner)
    }

    private func infoRow(key: String, value: String) -> UIView {
        let row = UIView()
        let k = UILabel()
        k.text = key
        k.font = .systemFont(ofSize: 14, weight: .medium)
        k.textColor = .label
        let v = UILabel()
        v.text = value
        v.font = .systemFont(ofSize: 14)
        v.textColor = .secondaryLabel
        v.textAlignment = .right
        v.numberOfLines = 0

        k.translatesAutoresizingMaskIntoConstraints = false
        v.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(k)
        row.addSubview(v)
        NSLayoutConstraint.activate([
            k.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
            k.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            k.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -10),
            v.centerYAnchor.constraint(equalTo: k.centerYAnchor),
            v.leadingAnchor.constraint(greaterThanOrEqualTo: k.trailingAnchor, constant: 8),
            v.trailingAnchor.constraint(equalTo: row.trailingAnchor)
        ])
        return row
    }

    private func separatorLine() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }

    private func setupPlaceholders() {
        for v in [estadisticasPlaceholder, alineacionesPlaceholder] {
            v.backgroundColor = .appBackground
            v.prepareForAutoLayout()
            contentContainer.addSubview(v)
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                v.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
                v.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
            ])
            v.isHidden = true
        }
    }

    private func setupEstadisticasTab() {
        estadisticasHost.prepareForAutoLayout()
        estadisticasPlaceholder.addSubview(estadisticasHost)
        NSLayoutConstraint.activate([
            estadisticasHost.topAnchor.constraint(equalTo: estadisticasPlaceholder.topAnchor),
            estadisticasHost.leadingAnchor.constraint(equalTo: estadisticasPlaceholder.leadingAnchor),
            estadisticasHost.trailingAnchor.constraint(equalTo: estadisticasPlaceholder.trailingAnchor),
            estadisticasHost.bottomAnchor.constraint(equalTo: estadisticasPlaceholder.bottomAnchor)
        ])

        let stack = estadisticasHost.contentStack

        let chips = MatchDetailTimeScopeChipRow()
        stack.addArrangedSubview(chips)
        stack.setCustomSpacing(Spacing.medium, after: chips)

        let listTitle = MatchDetailSectionHeading.label(title: "Estadísticas principales", uppercase: false)
        stack.addArrangedSubview(listTitle)
        stack.setCustomSpacing(Spacing.small, after: listTitle)

        stack.addArrangedStatRows(viewModel.estadisticasTabRows)
    }

    private func setupAlineacionesTab() {
        alineacionesHost.prepareForAutoLayout()
        alineacionesPlaceholder.addSubview(alineacionesHost)
        NSLayoutConstraint.activate([
            alineacionesHost.topAnchor.constraint(equalTo: alineacionesPlaceholder.topAnchor),
            alineacionesHost.leadingAnchor.constraint(equalTo: alineacionesPlaceholder.leadingAnchor),
            alineacionesHost.trailingAnchor.constraint(equalTo: alineacionesPlaceholder.trailingAnchor),
            alineacionesHost.bottomAnchor.constraint(equalTo: alineacionesPlaceholder.bottomAnchor)
        ])

        alineacionesHost.scrollView.isScrollEnabled = true
        alineacionesHost.scrollView.alwaysBounceVertical = true

        let pitch = MatchPitchLineupRootView(model: viewModel.lineupTabModel)
        pitch.prepareForAutoLayout()
        alineacionesHost.contentStack.addArrangedSubview(pitch)

        NSLayoutConstraint.activate([
            pitch.heightAnchor.constraint(equalTo: pitch.widthAnchor, multiplier: MatchPitchLineupRootView.heightPerWidth)
        ])
    }

    @objc private func segmentChanged() {
        let i = segmentedControl.selectedSegmentIndex
        resumenHost.isHidden = i != 0
        estadisticasPlaceholder.isHidden = i != 1
        alineacionesPlaceholder.isHidden = i != 2
    }

    @objc private func headphonesTapped() {}

    @objc private func shareTapped() {
        let av = UIActivityViewController(activityItems: [viewModel.shareText], applicationActivities: nil)
        av.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last
        present(av, animated: true)
    }
}
