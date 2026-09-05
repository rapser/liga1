//
//  MatchDetailViewController.swift
//  liga1
//

import UIKit
import Combine
import Kingfisher

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

    // MARK: - Termómetro del Arbitraje (rediseño Fan Experience)

    private func makeRefereePollSection() -> UIView {
        let card = FanCardView(title: "Termómetro del arbitraje", accentBorder: true)
        let inner = card.contentStack
        inner.spacing = Spacing.medium

        // Ficha compacta del árbitro (foto · nombre · penales por partido).
        if let nombre = viewModel.refereeNombreDisplay {
            inner.addArrangedSubview(refereeHeaderRow(nombre: nombre))
            inner.addArrangedSubview(FanCardView.separator())
        }

        if let pregunta = viewModel.refereePollPregunta {
            let q = UILabel()
            q.font = .systemFont(ofSize: 15, weight: .semibold)
            q.textColor = .label
            q.numberOfLines = 0
            q.text = pregunta
            inner.addArrangedSubview(q)
        }

        let opciones = viewModel.refereePollOpciones

        if viewModel.puedeVotarRefereePoll {
            inner.addArrangedSubview(pollOptionButtons(opciones))
        } else {
            for opcion in opciones {
                inner.addArrangedSubview(pollResultRow(for: opcion))
            }
            let bar = PollBarView()
            bar.setWeights(opciones.map(\.votos))
            inner.addArrangedSubview(bar)
        }

        let footer = UILabel()
        footer.font = .systemFont(ofSize: 12, weight: .medium)
        footer.textColor = viewModel.refereePollAbierta ? .liga1Gold : .secondaryLabel
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

        return card
    }

    private func refereeHeaderRow(nombre: String) -> UIView {
        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 20
        avatar.backgroundColor = .tertiarySystemFill
        avatar.tintColor = .secondaryLabel
        avatar.image = UIImage(systemName: "person.fill")
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40)
        ])
        if let urlString = viewModel.referee?.photoURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url, placeholder: UIImage(systemName: "person.fill"))
        }

        let rol = UILabel()
        rol.font = .systemFont(ofSize: 10, weight: .semibold)
        rol.textColor = .secondaryLabel
        rol.text = "JUEZ"

        let name = UILabel()
        name.font = .systemFont(ofSize: 16, weight: .bold)
        name.textColor = .label
        name.text = nombre
        name.numberOfLines = 1
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.8

        let idStack = UIStackView(arrangedSubviews: [rol, name])
        idStack.axis = .vertical
        idStack.spacing = 1

        let statStack = UIStackView()
        statStack.axis = .vertical
        statStack.alignment = .trailing
        statStack.spacing = 1
        if let penales = viewModel.refereePenalesPorPartidoDisplay {
            let cap = UILabel()
            cap.font = .systemFont(ofSize: 10, weight: .semibold)
            cap.textColor = .secondaryLabel
            cap.text = "PENALES / PARTIDO"
            let val = UILabel()
            val.font = .systemFont(ofSize: 15, weight: .bold)
            val.textColor = .liga1Gold
            val.text = penales
            statStack.addArrangedSubview(cap)
            statStack.addArrangedSubview(val)
        }

        let row = UIStackView(arrangedSubviews: [avatar, idStack, statStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = Spacing.medium
        idStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    private func pollOptionButtons(_ opciones: [MatchDetailViewModel.RefereePollOptionVM]) -> UIView {
        let row = UIStackView()
        row.axis = opciones.count <= 3 ? .horizontal : .vertical
        row.distribution = opciones.count <= 3 ? .fillEqually : .fill
        row.spacing = Spacing.small

        for opcion in opciones {
            var config = UIButton.Configuration.filled()
            config.title = opcion.texto
            config.baseBackgroundColor = pollButtonColor(for: opcion.id)
            config.baseForegroundColor = .white
            config.cornerStyle = .large
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            let b = UIButton(configuration: config)
            b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            b.isEnabled = !viewModel.pollVoteInFlight
            b.addAction(UIAction { [weak self] _ in
                self?.viewModel.voteRefereePoll(optionId: opcion.id)
            }, for: .touchUpInside)
            row.addArrangedSubview(b)
        }
        return row
    }

    private func pollButtonColor(for optionId: String) -> UIColor {
        switch optionId.lowercased() {
        case "si", "sí", "yes": return .appSuccess
        case "no": return .liga1Red
        default: return .liga1Gold
        }
    }

    private func pollResultRow(for opcion: MatchDetailViewModel.RefereePollOptionVM) -> UIView {
        let name = UILabel()
        name.font = .systemFont(ofSize: 14, weight: opcion.esMiVoto ? .semibold : .regular)
        name.textColor = opcion.esMiVoto ? .liga1Gold : .label
        name.text = opcion.esMiVoto ? "\(opcion.texto)  ✓" : opcion.texto

        let value = UILabel()
        value.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        value.textColor = .label
        value.textAlignment = .right
        value.text = "\(opcion.porcentaje)%"
        value.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [name, value])
        row.axis = .horizontal
        row.spacing = Spacing.small
        row.alignment = .firstBaseline
        return row
    }

    private func makeSaborLocalSection() -> UIView {
        let card = FanCardView(title: "Factor altura & clima")
        let inner = card.contentStack
        inner.spacing = Spacing.medium

        // Bloque geográfico centrado (ciudad + altitud).
        if viewModel.ciudadDisplay != nil || viewModel.altitudDisplay != nil {
            let geo = UIStackView()
            geo.axis = .vertical
            geo.alignment = .center
            geo.spacing = 2

            let cap = UILabel()
            cap.font = .systemFont(ofSize: 10, weight: .semibold)
            cap.textColor = .secondaryLabel
            cap.text = "GEOGRAFÍA DEL PARTIDO"
            geo.addArrangedSubview(cap)

            if let ciudad = viewModel.ciudadDisplay {
                let c = UILabel()
                c.font = .systemFont(ofSize: 20, weight: .bold)
                c.textColor = .label
                c.textAlignment = .center
                c.text = ciudad
                geo.addArrangedSubview(c)
            }
            if let alt = viewModel.altitudDisplay {
                let a = UILabel()
                a.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
                a.textColor = .liga1Gold
                a.text = alt.uppercased()
                geo.addArrangedSubview(a)
            }
            if let factor = viewModel.factorGeograficoDisplay {
                geo.addArrangedSubview(pill(text: factor))
            }
            inner.addArrangedSubview(geo)
        }

        // Dato histórico ("dato caleta").
        if let dato = viewModel.datoHistorico {
            inner.addArrangedSubview(FanCardView.separator())
            let cap = UILabel()
            cap.font = .systemFont(ofSize: 10, weight: .semibold)
            cap.textColor = .secondaryLabel
            cap.text = "DATO CALETA"
            let txt = UILabel()
            txt.font = .systemFont(ofSize: 13)
            txt.textColor = .label
            txt.numberOfLines = 0
            txt.text = dato
            let s = UIStackView(arrangedSubviews: [cap, txt])
            s.axis = .vertical
            s.spacing = 4
            inner.addArrangedSubview(s)
        }

        // Clima.
        if let resumen = viewModel.climaResumenDisplay {
            inner.addArrangedSubview(FanCardView.separator())

            let icon = UIImageView(image: UIImage(systemName: viewModel.climaIconoSF ?? "cloud.fill"))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .liga1Gold
            icon.setContentHuggingPriority(.required, for: .horizontal)

            let temp = UILabel()
            temp.font = .systemFont(ofSize: 17, weight: .bold)
            temp.textColor = .label
            temp.text = resumen

            let warn = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
            warn.tintColor = .appWarning
            warn.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            warn.isHidden = !viewModel.climaAdvertencia
            warn.setContentHuggingPriority(.required, for: .horizontal)

            let top = UIStackView(arrangedSubviews: [icon, temp, UIView(), warn])
            top.axis = .horizontal
            top.alignment = .center
            top.spacing = Spacing.small

            let climaStack = UIStackView(arrangedSubviews: [top])
            climaStack.axis = .vertical
            climaStack.spacing = 4
            if let detalle = viewModel.climaDetalleDisplay {
                let d = UILabel()
                d.font = .systemFont(ofSize: 12)
                d.textColor = .secondaryLabel
                d.text = detalle
                climaStack.addArrangedSubview(d)
            }
            inner.addArrangedSubview(climaStack)
        }

        return card
    }

    /// Pequeña "pastilla" de texto (badge) con acento dorado.
    private func pill(text: String) -> UIView {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = .liga1Gold
        l.translatesAutoresizingMaskIntoConstraints = false

        let bg = UIView()
        bg.backgroundColor = UIColor.liga1Gold.withAlphaComponent(0.15)
        bg.layer.cornerRadius = 8
        bg.layer.masksToBounds = true
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: bg.topAnchor, constant: 4),
            l.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -4),
            l.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 10),
            l.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -10)
        ])
        // El padre (`geo`, alignment .center) lo centra usando su ancho intrínseco.
        return bg
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
        // Si hay encuesta arbitral, la ficha del juez ya se muestra en esa card.
        if !viewModel.refereePollDisponible, let nombreArbitro = viewModel.refereeNombreDisplay {
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
