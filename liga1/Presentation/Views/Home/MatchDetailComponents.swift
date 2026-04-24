//
//  MatchDetailComponents.swift
//  liga1
//
//  Vistas reutilizables del detalle de partido (scroll + secciones + estadísticas).
//

import UIKit

// MARK: - Scroll + stack vertical con márgenes estándar

final class MatchDetailScrollStackView: UIView {

    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    init(
        scrollBackgroundColor: UIColor = .clear,
        contentTopInset: CGFloat = Spacing.standard,
        contentBottomInset: CGFloat = Spacing.large,
        contentHorizontalInset: CGFloat = Spacing.standard
    ) {
        super.init(frame: .zero)
        prepareForAutoLayout()
        scrollView.prepareForAutoLayout()
        contentStack.prepareForAutoLayout()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = scrollBackgroundColor
        contentStack.axis = .vertical
        contentStack.spacing = Spacing.medium
        contentStack.alignment = .fill

        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: contentTopInset),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: contentHorizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -contentHorizontalInset),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -contentBottomInset),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * contentHorizontalInset)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Bloque título + contenido (Resumen / Estadísticas)

final class MatchDetailTitledSectionView: UIView {

    init(title: String, uppercaseTitle: Bool = true, content: UIView) {
        super.init(frame: .zero)
        let heading = UILabel()
        heading.text = uppercaseTitle ? title.uppercased() : title
        heading.font = .systemFont(ofSize: 12, weight: .semibold)
        heading.textColor = .secondaryLabel
        heading.prepareForAutoLayout()
        content.prepareForAutoLayout()

        addSubview(heading)
        addSubview(content)

        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: topAnchor),
            heading.leadingAnchor.constraint(equalTo: leadingAnchor),
            heading.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: Spacing.small),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sección “Estadísticas” del resumen: título en mayúsculas + filas comparativas.
    static func statRowsSection(title: String, rows: [MatchDetailStatRow]) -> MatchDetailTitledSectionView {
        let inner = UIStackView()
        inner.prepareForAutoLayout()
        inner.axis = .vertical
        inner.spacing = Spacing.medium
        inner.addArrangedStatRows(rows)
        return MatchDetailTitledSectionView(title: title, uppercaseTitle: true, content: inner)
    }
}

// MARK: - Solo título de bloque (sin contenido debajo en el mismo view)

enum MatchDetailSectionHeading {
    static func label(title: String, uppercase: Bool = true) -> UILabel {
        let l = UILabel()
        l.text = uppercase ? title.uppercased() : title
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }
}

// MARK: - Fila de chips PARTIDO / tiempos

final class MatchDetailTimeScopeChipRow: UIStackView {

    private static let titles = ["PARTIDO", "1ER TIEMPO", "2º TIEMPO"]

    private(set) var selectedIndex: Int = 0
    var onSelectionChange: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 8
        alignment = .center
        distribution = .fillProportionally

        for (idx, title) in Self.titles.enumerated() {
            let btn = UIButton(type: .system)
            btn.tag = idx
            btn.configuration = Self.chipConfiguration(title: title, selected: idx == 0)
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            addArrangedSubview(btn)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectChip(at index: Int) {
        guard index >= 0, index < Self.titles.count else { return }
        selectedIndex = index
        for case let btn as UIButton in arrangedSubviews {
            let title = Self.titles[btn.tag]
            btn.configuration = Self.chipConfiguration(title: title, selected: btn.tag == index)
        }
    }

    @objc private func tapped(_ sender: UIButton) {
        selectChip(at: sender.tag)
        onSelectionChange?(sender.tag)
    }

    private static func chipConfiguration(title: String, selected: Bool) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.background.cornerRadius = 16
        config.background.strokeWidth = selected ? 0 : 1
        config.background.strokeColor = UIColor.separator
        config.background.backgroundColor = selected ? .liga1Red : .clear
        config.baseForegroundColor = selected ? .white : .label
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            return out
        }
        return config
    }
}

// MARK: - Filas de estadística + barra

extension UIStackView {
    func addArrangedStatRows(_ rows: [MatchDetailStatRow]) {
        rows.forEach { addArrangedSubview(MatchStatComparisonRowView(row: $0)) }
    }
}

final class MatchStatComparisonRowView: UIView {

    init(row: MatchDetailStatRow) {
        super.init(frame: .zero)
        let title = UILabel()
        title.text = row.title
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .secondaryLabel
        title.textAlignment = .center
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let lv = Self.valueColumn(
            main: row.localDisplay,
            subtitle: row.localSubtitle,
            alignment: .leading
        )
        let vv = Self.valueColumn(
            main: row.visitanteDisplay,
            subtitle: row.visitanteSubtitle,
            alignment: .trailing
        )

        let bar = ComparisonBarView(local: row.localMagnitude, visitante: row.visitanteMagnitude)

        let headerRow = UIStackView(arrangedSubviews: [lv, title, vv])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 8
        headerRow.distribution = .fill

        let stack = UIStackView(arrangedSubviews: [headerRow, bar])
        stack.axis = .vertical
        stack.spacing = 6
        stack.prepareForAutoLayout()
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func valueColumn(main: String, subtitle: String?, alignment: UIStackView.Alignment) -> UIView {
        let mainL = UILabel()
        mainL.text = main
        mainL.font = .systemFont(ofSize: 14, weight: .semibold)
        mainL.textColor = .label
        mainL.textAlignment = alignment == .leading ? .left : .right

        let textAlignment: NSTextAlignment = alignment == .leading ? .left : .right

        if let subtitle = subtitle {
            let subL = UILabel()
            subL.text = subtitle
            subL.font = .systemFont(ofSize: 11, weight: .regular)
            subL.textColor = .secondaryLabel
            subL.textAlignment = textAlignment
            let col = UIStackView(arrangedSubviews: [mainL, subL])
            col.axis = .vertical
            col.alignment = alignment
            col.spacing = 2
            col.setContentCompressionResistancePriority(.required, for: .horizontal)
            col.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            return col
        }

        mainL.setContentCompressionResistancePriority(.required, for: .horizontal)
        mainL.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return mainL
    }
}

final class ComparisonBarView: UIView {

    init(local: Double, visitante: Double) {
        super.init(frame: .zero)
        let track = UIView()
        track.layer.cornerRadius = 3
        track.clipsToBounds = true
        track.backgroundColor = .tertiarySystemFill

        let localPart = UIView()
        localPart.backgroundColor = .statComparisonLocal
        let visitPart = UIView()
        visitPart.backgroundColor = .statComparisonVisitante

        track.prepareForAutoLayout()
        localPart.prepareForAutoLayout()
        visitPart.prepareForAutoLayout()
        addSubview(track)
        track.addSubview(localPart)
        track.addSubview(visitPart)

        let l = max(0, local)
        let r = max(0, visitante)
        let total = l + r
        let ratio: CGFloat
        if total <= 0 {
            ratio = 0.5
        } else {
            ratio = CGFloat(l / total)
        }

        NSLayoutConstraint.activate([
            track.topAnchor.constraint(equalTo: topAnchor),
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            localPart.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            localPart.topAnchor.constraint(equalTo: track.topAnchor),
            localPart.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            visitPart.trailingAnchor.constraint(equalTo: track.trailingAnchor),
            visitPart.topAnchor.constraint(equalTo: track.topAnchor),
            visitPart.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            localPart.trailingAnchor.constraint(equalTo: visitPart.leadingAnchor),
            localPart.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: ratio),
            visitPart.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: 1.0 - ratio)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
