//
//  MatchLineupComponents.swift
//  liga1
//
//  Cancha con proporción fija; jugadores posicionados según el área de juego (inset) y formación.
//

import UIKit

// MARK: - Raíz: aspecto fijo (alto = ancho × factor), mismo en todas las pantallas

final class MatchPitchLineupRootView: UIView {

    /// Alto del campo respecto al ancho (cancha alargada en vertical).
    static let heightPerWidth: CGFloat = 1.52

    private let grass = MatchPitchGrassView()
    private let markings = MatchPitchMarkingsView()
    private let overlay: LineupPlayersOverlayView

    init(model: MatchLineupTabModel) {
        overlay = LineupPlayersOverlayView(visit: model.visitTop, local: model.localBottom)
        super.init(frame: .zero)
        prepareForAutoLayout()
        grass.prepareForAutoLayout()
        markings.prepareForAutoLayout()
        overlay.prepareForAutoLayout()
        isUserInteractionEnabled = true
        addSubview(grass)
        addSubview(markings)
        addSubview(overlay)
        NSLayoutConstraint.activate([
            grass.topAnchor.constraint(equalTo: topAnchor),
            grass.leadingAnchor.constraint(equalTo: leadingAnchor),
            grass.trailingAnchor.constraint(equalTo: trailingAnchor),
            grass.bottomAnchor.constraint(equalTo: bottomAnchor),
            markings.topAnchor.constraint(equalTo: topAnchor),
            markings.leadingAnchor.constraint(equalTo: leadingAnchor),
            markings.trailingAnchor.constraint(equalTo: trailingAnchor),
            markings.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overlay de jugadores (coordenadas = mismo inset que el dibujo de cancha)

private final class LineupPlayersOverlayView: UIView {

    private let visit: TeamLineupSideModel
    private let local: TeamLineupSideModel
    private var visitChips: [LineupPlayerChipView] = []
    private var localChips: [LineupPlayerChipView] = []
    private var visitBadge: TeamAverageRatingBadge?
    private var localBadge: TeamAverageRatingBadge?

    init(visit: TeamLineupSideModel, local: TeamLineupSideModel) {
        self.visit = visit
        self.local = local
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        for p in visit.players {
            let c = LineupPlayerChipView(data: p)
            c.translatesAutoresizingMaskIntoConstraints = true
            visitChips.append(c)
            addSubview(c)
        }
        for p in local.players {
            let c = LineupPlayerChipView(data: p)
            c.translatesAutoresizingMaskIntoConstraints = true
            localChips.append(c)
            addSubview(c)
        }

        if let avg = visit.averageRating {
            let b = TeamAverageRatingBadge(rating: avg)
            b.translatesAutoresizingMaskIntoConstraints = true
            visitBadge = b
            addSubview(b)
        }
        if let avg = local.averageRating {
            let b = TeamAverageRatingBadge(rating: avg)
            b.translatesAutoresizingMaskIntoConstraints = true
            localBadge = b
            addSubview(b)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Mismo inset horizontal/vertical que el dibujo de cancha.
    private static func playInset(in bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 3, dy: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = Self.playInset(in: bounds)
        guard inset.width > 20, inset.height > 20 else { return }

        let midY = bounds.midY
        let chipW: CGFloat = 54
        let chipH: CGFloat = 58

        let visitRows = visit.formation.rowSlices(of: visit.players)
        let depthVisit = midY - inset.minY
        var vIdx = 0
        let rv = max(visitRows.count, 1)
        for (i, row) in visitRows.enumerated() {
            let n = max(row.count, 1)
            let vFrac = (CGFloat(i) + 0.5) / CGFloat(rv)
            let y = inset.minY + depthVisit * (0.06 + vFrac * 0.88)
            for (j, _) in row.enumerated() {
                let x = inset.minX + (CGFloat(j) + 0.5) / CGFloat(n) * inset.width
                visitChips[vIdx].frame = CGRect(
                    x: x - chipW / 2,
                    y: y - chipH / 2,
                    width: chipW,
                    height: chipH
                )
                vIdx += 1
            }
        }

        let localRows = local.formation.rowSlices(of: local.players).reversed()
        let depthLocal = inset.maxY - midY
        var lIdx = 0
        let rl = max(localRows.count, 1)
        for (i, row) in localRows.enumerated() {
            let n = max(row.count, 1)
            let vFrac = (CGFloat(i) + 0.5) / CGFloat(rl)
            let y = midY + depthLocal * (0.06 + vFrac * 0.88)
            for (j, _) in row.enumerated() {
                let x = inset.minX + (CGFloat(j) + 0.5) / CGFloat(n) * inset.width
                localChips[lIdx].frame = CGRect(
                    x: x - chipW / 2,
                    y: y - chipH / 2,
                    width: chipW,
                    height: chipH
                )
                lIdx += 1
            }
        }

        if let b = visitBadge {
            let sz = b.intrinsicContentSize
            b.frame = CGRect(x: inset.minX + 4, y: inset.minY + 4, width: sz.width, height: sz.height)
        }
        if let b = localBadge {
            let sz = b.intrinsicContentSize
            b.frame = CGRect(x: inset.maxX - sz.width - 6, y: inset.maxY - sz.height - 6, width: sz.width, height: sz.height)
        }
    }
}

// MARK: - Césped (solo relleno; debajo de todas las líneas)

private final class MatchPitchGrassView: UIView {

    private let pitchFill = UIColor(red: 0.09, green: 0.2, blue: 0.19, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let inset = bounds.insetBy(dx: 3, dy: 4)
        guard inset.width > 24, inset.height > 24 else { return }
        let corner: CGFloat = 12
        let border = UIBezierPath(roundedRect: inset, cornerRadius: corner)
        pitchFill.setFill()
        border.fill()
    }
}

// MARK: - Líneas de cancha (encima del césped, debajo de jugadores)

private final class MatchPitchMarkingsView: UIView {

    private let lineColor = UIColor.white.withAlphaComponent(0.52)
    private let lineWidth: CGFloat = 1.15
    private let penaltyArcLineWidth: CGFloat = 1.35

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let inset = bounds.insetBy(dx: 3, dy: 4)
        guard inset.width > 24, inset.height > 24 else { return }

        let corner: CGFloat = 12
        let border = UIBezierPath(roundedRect: inset, cornerRadius: corner)

        func stroke(_ path: UIBezierPath, width: CGFloat? = nil) {
            path.lineWidth = width ?? lineWidth
            lineColor.setStroke()
            path.stroke()
        }

        func fillDisc(_ path: UIBezierPath) {
            lineColor.setFill()
            path.fill()
        }

        func strokePenaltyArcClipped(_ path: UIBezierPath, clipRect: CGRect) {
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.saveGState()
            ctx.clip(to: clipRect)
            path.lineWidth = penaltyArcLineWidth
            lineColor.setStroke()
            path.stroke()
            ctx.restoreGState()
        }

        lineColor.setStroke()
        border.lineWidth = lineWidth
        border.stroke()

        let W = inset.width
        let H = inset.height
        let mx = inset.midX
        let my = inset.midY

        let halfway = UIBezierPath()
        halfway.move(to: CGPoint(x: inset.minX + lineWidth, y: my))
        halfway.addLine(to: CGPoint(x: inset.maxX - lineWidth, y: my))
        stroke(halfway)

        let rCenter = min(W, H) * 0.104
        stroke(UIBezierPath(
            arcCenter: CGPoint(x: mx, y: my),
            radius: rCenter,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        ))

        let spotR: CGFloat = 2.6
        fillDisc(UIBezierPath(ovalIn: CGRect(x: mx - spotR, y: my - spotR, width: spotR * 2, height: spotR * 2)))

        let penD = H * 0.166
        let penW = W * 0.56
        let penX = mx - penW / 2
        stroke(UIBezierPath(rect: CGRect(x: penX, y: inset.minY, width: penW, height: penD)))
        stroke(UIBezierPath(rect: CGRect(x: penX, y: inset.maxY - penD, width: penW, height: penD)))

        let sixD = H * 0.05
        let sixW = W * 0.22
        let sixX = mx - sixW / 2
        stroke(UIBezierPath(rect: CGRect(x: sixX, y: inset.minY, width: sixW, height: sixD)))
        stroke(UIBezierPath(rect: CGRect(x: sixX, y: inset.maxY - sixD, width: sixW, height: sixD)))

        let penSpotYOff = penD * (11.0 / 16.5)
        let spotTopY = inset.minY + penSpotYOff
        let spotBotY = inset.maxY - penSpotYOff
        let psR: CGFloat = 2.2
        fillDisc(UIBezierPath(ovalIn: CGRect(x: mx - psR, y: spotTopY - psR, width: psR * 2, height: psR * 2)))
        fillDisc(UIBezierPath(ovalIn: CGRect(x: mx - psR, y: spotBotY - psR, width: psR * 2, height: psR * 2)))

        let cR = min(W, H) * 0.036
        stroke(UIBezierPath(arcCenter: CGPoint(x: inset.minX, y: inset.minY), radius: cR, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true))
        stroke(UIBezierPath(arcCenter: CGPoint(x: inset.maxX, y: inset.minY), radius: cR, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true))
        stroke(UIBezierPath(arcCenter: CGPoint(x: inset.maxX, y: inset.maxY), radius: cR, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true))
        stroke(UIBezierPath(arcCenter: CGPoint(x: inset.minX, y: inset.maxY), radius: cR, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true))

        // Medialuna: arco exterior al área. En UIKit los ángulos avanzan en sentido horario; el arco corto
        // correcto hacia el campo usa clockwise: true arriba y false abajo (antes estaba invertido y el clip lo anulaba).
        let penaltyArcRadius = penD * (9.15 / 16.5)
        let frontTop = inset.minY + penD
        let frontBottom = inset.maxY - penD

        func penaltyArcPathTop(spot: CGPoint) -> UIBezierPath? {
            let dy = frontTop - spot.y
            let r = penaltyArcRadius
            guard r * r >= dy * dy - 0.25 else { return nil }
            let halfChord = sqrt(max(0, r * r - dy * dy))
            let angleRight = atan2(dy, halfChord)
            let angleLeft = atan2(dy, -halfChord)
            return UIBezierPath(
                arcCenter: spot,
                radius: r,
                startAngle: angleRight,
                endAngle: angleLeft,
                clockwise: true
            )
        }

        func penaltyArcPathBottom(spot: CGPoint) -> UIBezierPath? {
            let dy = frontBottom - spot.y
            let r = penaltyArcRadius
            guard r * r >= dy * dy - 0.25 else { return nil }
            let halfChord = sqrt(max(0, r * r - dy * dy))
            var start = atan2(dy, halfChord)
            var end = atan2(dy, -halfChord)
            if start < 0 { start += 2 * .pi }
            if end < 0 { end += 2 * .pi }
            return UIBezierPath(
                arcCenter: spot,
                radius: r,
                startAngle: start,
                endAngle: end,
                clockwise: false
            )
        }

        let clipTopArc = CGRect(x: inset.minX, y: frontTop, width: inset.width, height: inset.maxY - frontTop)
        let clipBottomArc = CGRect(x: inset.minX, y: inset.minY, width: inset.width, height: frontBottom - inset.minY)

        if let path = penaltyArcPathTop(spot: CGPoint(x: mx, y: spotTopY)) {
            strokePenaltyArcClipped(path, clipRect: clipTopArc)
        }
        if let path = penaltyArcPathBottom(spot: CGPoint(x: mx, y: spotBotY)) {
            strokePenaltyArcClipped(path, clipRect: clipBottomArc)
        }
    }
}

// MARK: - Badge nota media

private final class TeamAverageRatingBadge: UIView {

    private let label = UILabel()

    init(rating: Double) {
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 0.92, green: 0.52, blue: 0.14, alpha: 1)
        layer.cornerRadius = 9
        clipsToBounds = true
        label.text = String(format: "ø %.1f", rating)
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let s = label.sizeThatFits(CGSize(width: 160, height: 40))
        return CGSize(width: s.width + 14, height: max(s.height + 8, 22))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 7, y: 3, width: max(bounds.width - 14, 0), height: max(bounds.height - 6, 0))
    }
}

// MARK: - Ficha jugador (layout interno por frames para poder mover en cancha)

final class LineupPlayerChipView: UIView {

    init(data: LineupPlayerUIData) {
        super.init(frame: .zero)
        backgroundColor = .clear

        let avatarSize: CGFloat = 32
        let avatar = UIImageView(image: UIImage(systemName: "person.fill"))
        avatar.tintColor = .tertiaryLabel
        avatar.backgroundColor = .tertiarySystemFill
        avatar.contentMode = .scaleAspectFit
        avatar.layer.cornerRadius = avatarSize / 2
        avatar.clipsToBounds = true
        avatar.frame = CGRect(x: (54 - avatarSize) / 2, y: 0, width: avatarSize, height: avatarSize)
        addSubview(avatar)

        if data.scoredGoal {
            let ball = UIImageView(
                image: UIImage(systemName: "soccerball", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .semibold))
            )
            ball.tintColor = .white
            ball.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            ball.layer.cornerRadius = 6
            ball.clipsToBounds = true
            ball.frame = CGRect(x: avatar.frame.minX - 2, y: -1, width: 13, height: 13)
            addSubview(ball)
        }

        if let r = data.rating {
            let badge = UILabel()
            badge.text = String(format: "%.1f", r)
            badge.font = .systemFont(ofSize: 8, weight: .bold)
            badge.textColor = .white
            badge.textAlignment = .center
            badge.backgroundColor = Self.ratingColor(r)
            badge.layer.cornerRadius = 3
            badge.clipsToBounds = true
            let bw: CGFloat = 26
            let bh: CGFloat = 14
            badge.frame = CGRect(x: avatar.frame.maxX - bw + 8, y: avatar.frame.maxY - bh + 4, width: bw, height: bh)
            addSubview(badge)
        }

        let name = UILabel()
        name.text = "\(data.number) \(data.shortName)"
        name.font = .systemFont(ofSize: 12, weight: .medium)
        name.textColor = .white
        name.textAlignment = .center
        name.numberOfLines = 1
        name.lineBreakMode = .byTruncatingTail
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.65
        name.frame = CGRect(x: 0, y: avatarSize + 1, width: 54, height: 20)
        addSubview(name)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private static func ratingColor(_ r: Double) -> UIColor {
        if r >= 7.0 { return UIColor(red: 0.2, green: 0.65, blue: 0.35, alpha: 1) }
        if r >= 6.0 { return UIColor(red: 0.9, green: 0.55, blue: 0.12, alpha: 1) }
        return UIColor(red: 0.85, green: 0.22, blue: 0.2, alpha: 1)
    }
}
