//
//  HomeMatchesListSkeletonView.swift
//  liga1
//

import UIKit

/// Lista ficticia mientras carga Inicio; evita mostrar “Sin partidos” antes de conocer el resultado.
final class HomeMatchesListSkeletonView: UIView {

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
        a.toValue = 0.5
        a.duration = 0.75
        a.autoreverses = true
        a.repeatCount = .infinity
        a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        contentStack.layer.add(a, forKey: "homeSkeletonPulse")
    }

    func stopAnimating() {
        isAnimating = false
        contentStack.layer.removeAnimation(forKey: "homeSkeletonPulse")
        contentStack.alpha = 1
        isHidden = true
    }

    private func configure() {
        backgroundColor = .clear
        clipsToBounds = true
        isAccessibilityElement = true
        accessibilityLabel = "Cargando partidos"

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

        contentStack.addArrangedSubview(makeSectionHeaderSkeleton())
        for _ in 0..<5 {
            contentStack.addArrangedSubview(makeMatchRowSkeleton())
        }
    }

    private func makeSectionHeaderSkeleton() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let topBand = UIView()
        topBand.backgroundColor = .systemBackground
        let dateBar = skeletonCapsule(height: 14)
        topBand.addSubview(dateBar)
        dateBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateBar.leadingAnchor.constraint(equalTo: topBand.leadingAnchor, constant: Spacing.standard),
            dateBar.centerYAnchor.constraint(equalTo: topBand.centerYAnchor),
            dateBar.widthAnchor.constraint(equalTo: topBand.widthAnchor, multiplier: 0.42)
        ])

        let jornadaBand = UIView()
        jornadaBand.backgroundColor = .secondarySystemBackground
        let titleBar = skeletonCapsule(height: 18)
        let subtitleBar = skeletonCapsule(height: 12)
        let jStack = UIStackView(arrangedSubviews: [titleBar, subtitleBar])
        jStack.axis = .vertical
        jStack.spacing = Spacing.tiny
        jStack.alignment = .leading
        jStack.translatesAutoresizingMaskIntoConstraints = false
        jornadaBand.addSubview(jStack)
        NSLayoutConstraint.activate([
            jStack.leadingAnchor.constraint(equalTo: jornadaBand.leadingAnchor, constant: Spacing.standard),
            jStack.trailingAnchor.constraint(lessThanOrEqualTo: jornadaBand.trailingAnchor, constant: -Spacing.standard),
            jStack.topAnchor.constraint(equalTo: jornadaBand.topAnchor, constant: Spacing.small),
            jStack.bottomAnchor.constraint(equalTo: jornadaBand.bottomAnchor, constant: -Spacing.small),
            titleBar.widthAnchor.constraint(equalTo: jornadaBand.widthAnchor, multiplier: 0.35),
            subtitleBar.widthAnchor.constraint(equalTo: jornadaBand.widthAnchor, multiplier: 0.55)
        ])

        let vStack = UIStackView(arrangedSubviews: [topBand, jornadaBand])
        vStack.axis = .vertical
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(vStack)

        NSLayoutConstraint.activate([
            topBand.heightAnchor.constraint(equalToConstant: 44),
            vStack.topAnchor.constraint(equalTo: container.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeMatchRowSkeleton() -> UIView {
        let row = UIView()
        row.backgroundColor = .systemBackground

        let logoL = skeletonCircle(diameter: 28)
        let logoV = skeletonCircle(diameter: 28)
        let nameL = skeletonCapsule(height: 12)
        let nameV = skeletonCapsule(height: 12)
        let leftStack = UIStackView()
        leftStack.axis = .vertical
        leftStack.spacing = 10
        leftStack.alignment = .leading
        leftStack.addArrangedSubview(nameRow(logo: logoL, bar: nameL))
        leftStack.addArrangedSubview(nameRow(logo: logoV, bar: nameV))

        let scoreBlock = UIView()
        scoreBlock.backgroundColor = .secondarySystemFill
        scoreBlock.layer.cornerRadius = 4
        scoreBlock.translatesAutoresizingMaskIntoConstraints = false

        let h = UIStackView(arrangedSubviews: [leftStack, UIView(), scoreBlock])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(h)

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            h.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20),
            h.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            h.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12),
            scoreBlock.widthAnchor.constraint(equalToConstant: 36),
            scoreBlock.heightAnchor.constraint(equalToConstant: 44),
            nameL.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.5),
            nameV.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.45)
        ])
        return row
    }

    private func nameRow(logo: UIView, bar: UIView) -> UIView {
        let h = UIStackView(arrangedSubviews: [logo, bar])
        h.axis = .horizontal
        h.spacing = 10
        h.alignment = .center
        return h
    }

    private func skeletonCircle(diameter: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemFill
        v.layer.cornerRadius = diameter / 2
        v.translatesAutoresizingMaskIntoConstraints = false
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
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }
}
