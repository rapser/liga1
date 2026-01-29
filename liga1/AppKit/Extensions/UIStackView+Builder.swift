//
//  UIStackView+Builder.swift
//  liga1
//
//  Created by Miguel Tomairo on 01/01/26.
//

import UIKit

// MARK: - UIStackView Builder
extension UIStackView {

    /// Crea un HStack (horizontal stack)
    static func hStack(
        spacing: CGFloat = Spacing.small,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        @ViewBuilder views: () -> [UIView]
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views())
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    /// Crea un VStack (vertical stack)
    static func vStack(
        spacing: CGFloat = Spacing.small,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        @ViewBuilder views: () -> [UIView]
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views())
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    /// Agrega vistas al stack
    @discardableResult
    func addArranged(_ views: [UIView]) -> Self {
        views.forEach { addArrangedSubview($0) }
        return self
    }

    /// Agrega una vista al stack
    @discardableResult
    func addArranged(_ view: UIView) -> Self {
        addArrangedSubview(view)
        return self
    }

    /// Establece el spacing
    @discardableResult
    func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    /// Establece el alignment
    @discardableResult
    func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    /// Establece la distribución
    @discardableResult
    func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    /// Establece el eje
    @discardableResult
    func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }

    /// Agrega padding interno al stack
    @discardableResult
    func padding(_ insets: UIEdgeInsets) -> Self {
        layoutMargins = insets
        isLayoutMarginsRelativeArrangement = true
        return self
    }

    /// Agrega padding simétrico
    @discardableResult
    func padding(_ padding: CGFloat) -> Self {
        return self.padding(UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
}

// MARK: - View Builder
@resultBuilder
struct ViewBuilder {
    static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }

    static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }

    static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }

    static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }

    static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }
}

// MARK: - Spacer Helper
class Spacer: UIView {
    init(width: CGFloat? = nil, height: CGFloat? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
