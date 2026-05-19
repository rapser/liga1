//
//  FavoritosSkeletonView.swift
//  liga1
//

import UIKit

/// Placeholder animado que se muestra mientras cargan los equipos favoritos;
/// imita el layout de TeamTableViewCell para evitar el salto visual al revelar contenido.
final class FavoritosSkeletonView: UIView {

    private let contentStack = UIStackView()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        isHidden = false
        let a = CABasicAnimation(keyPath: "opacity")
        a.fromValue = 1.0
        a.toValue = 0.4
        a.duration = 0.8
        a.autoreverses = true
        a.repeatCount = .infinity
        a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        contentStack.layer.add(a, forKey: "favSkeletonPulse")
    }

    func stopAnimating() {
        isAnimating = false
        contentStack.layer.removeAnimation(forKey: "favSkeletonPulse")
        contentStack.alpha = 1
        isHidden = true
    }

    // MARK: - Private

    private func configure() {
        backgroundColor = .clear
        isHidden = true
        isAccessibilityElement = true
        accessibilityLabel = "Cargando favoritos"

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

        contentStack.addArrangedSubview(makeHeaderSkeleton())
        for _ in 0..<5 {
            contentStack.addArrangedSubview(makeRowSkeleton())
        }
    }

    /// Imita el header "Mis Equipos Favoritos" de la sección.
    private func makeHeaderSkeleton() -> UIView {
        let container = UIView()

        let bar = skeletonCapsule(height: 15)
        bar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bar)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Spacing.standard),
            bar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            bar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.45)
        ])
        return container
    }

    /// Imita una fila de TeamTableViewCell: logo (círculo 40 pt) + nombre + estrella.
    private func makeRowSkeleton() -> UIView {
        let row = UIView()
        row.backgroundColor = .systemBackground

        let logo = skeletonCircle(diameter: 40)
        let nameBar = skeletonCapsule(height: 14)
        let star = skeletonCircle(diameter: 22)

        [logo, nameBar, star].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 70),

            logo.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Spacing.standard),
            logo.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            star.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Spacing.standard),
            star.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            nameBar.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: Spacing.medium),
            nameBar.trailingAnchor.constraint(equalTo: star.leadingAnchor, constant: -Spacing.medium),
            nameBar.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameBar.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.5)
        ])

        let sep = UIView()
        sep.backgroundColor = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(sep)
        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        return row
    }

    private func skeletonCircle(diameter: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemFill
        v.layer.cornerRadius = diameter / 2
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: diameter),
            v.heightAnchor.constraint(equalToConstant: diameter)
        ])
        return v
    }

    private func skeletonCapsule(height: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemFill
        v.layer.cornerRadius = height / 2
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }
}
