//
//  MatchDetailViewController.swift
//  liga1
//

import UIKit

final class MatchDetailViewController: UIViewController {

    private let viewModel: MatchDetailViewModel

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
        segmentChanged()
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
        stack.addArrangedSubview(makeInfoAdicionalSection())
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

        inner.addArrangedSubview(infoRow(key: "Árbitro", value: viewModel.arbitroDisplay))
        inner.addArrangedSubview(separatorLine())
        inner.addArrangedSubview(infoRow(key: "Estadio", value: viewModel.estadioDisplay))
        inner.addArrangedSubview(separatorLine())
        inner.addArrangedSubview(infoRow(key: "Capacidad", value: viewModel.capacidadDisplay))

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
