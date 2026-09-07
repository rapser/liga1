//
//  PollBarView.swift
//  liga1
//
//  Barra de resultados de encuesta: segmentos proporcionales a los votos.
//  El primer segmento va en dorado, el resto en gris (estilo del rediseño).
//

import UIKit

final class PollBarView: UIView {

    private let track = UIStackView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        track.axis = .horizontal
        track.distribution = .fill
        track.spacing = 2
        track.translatesAutoresizingMaskIntoConstraints = false
        addSubview(track)
        NSLayoutConstraint.activate([
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.topAnchor.constraint(equalTo: topAnchor),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 8)
        ])
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no soportado") }

    /// `weights` = votos por opción, en el mismo orden que las opciones.
    func setWeights(_ weights: [Int]) {
        track.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !weights.isEmpty else { return }

        let palette: [UIColor] = [.liga1Gold, UIColor(white: 0.45, alpha: 1), .sudamericanaBlue, .appSuccess]
        let hasVotes = weights.contains { $0 > 0 }
        let total = CGFloat(max(1, weights.reduce(0, +)))

        // Fracciones que suman 1 (reparto uniforme si aún no hay votos).
        let fractions: [CGFloat] = weights.map { w in
            hasVotes ? CGFloat(w) / total : 1.0 / CGFloat(weights.count)
        }

        for (index, fraction) in fractions.enumerated() {
            let segment = UIView()
            segment.backgroundColor = palette[index % palette.count]
            segment.translatesAutoresizingMaskIntoConstraints = false
            track.addArrangedSubview(segment)

            if index < fractions.count - 1 {
                let c = segment.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: max(0.0001, fraction))
                c.priority = .defaultHigh   // el último segmento absorbe el redondeo
                c.isActive = true
            }
        }
    }
}
