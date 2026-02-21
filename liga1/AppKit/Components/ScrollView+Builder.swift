//
//  ScrollView+Builder.swift
//  liga1
//
//  Created by AppKit
//  Builder pattern para UIScrollView + helper para scroll con stack interno
//

import UIKit

// MARK: - UIScrollView Builder Extension

extension UIScrollView {

    @discardableResult
    func showsVerticalIndicator(_ shows: Bool) -> Self {
        showsVerticalScrollIndicator = shows
        return self
    }

    @discardableResult
    func showsHorizontalIndicator(_ shows: Bool) -> Self {
        showsHorizontalScrollIndicator = shows
        return self
    }

    @discardableResult
    func keyboardDismiss(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func contentInsets(_ inset: UIEdgeInsets) -> Self {
        contentInset = inset
        return self
    }

    @discardableResult
    func bounces(_ bounces: Bool) -> Self {
        self.bounces = bounces
        return self
    }

    @discardableResult
    func pagingEnabled(_ enabled: Bool) -> Self {
        isPagingEnabled = enabled
        return self
    }
}

// MARK: - Scrollable Stack View

/// Crea un UIScrollView con un UIStackView interno para contenido scrolleable
/// Ideal para formularios, pantallas de settings, o cualquier contenido vertical largo
class ScrollableStackView: UIView {

    // MARK: - Properties

    let scrollView = UIScrollView()
    let contentStack: UIStackView

    // MARK: - Initialization

    /// Crea un scroll view con un stack vertical interno
    init(
        spacing: CGFloat = Spacing.standard,
        padding: UIEdgeInsets = UIEdgeInsets(top: Spacing.standard, left: Spacing.standard, bottom: Spacing.standard, right: Spacing.standard),
        alignment: UIStackView.Alignment = .fill
    ) {
        contentStack = UIStackView()
        super.init(frame: .zero)

        contentStack.axis = .vertical
        contentStack.spacing = spacing
        contentStack.alignment = alignment
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive

        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: padding.top),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: padding.left),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -padding.right),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -padding.bottom),

            // Fijar el ancho del content al scroll view (scroll solo vertical)
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(padding.left + padding.right))
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Builder Methods

    /// Agrega una vista al stack
    @discardableResult
    func addContent(_ view: UIView) -> Self {
        contentStack.addArrangedSubview(view)
        return self
    }

    /// Agrega múltiples vistas al stack
    @discardableResult
    func addContent(@ViewBuilder views: () -> [UIView]) -> Self {
        views().forEach { contentStack.addArrangedSubview($0) }
        return self
    }

    /// Agrega un espacio fijo
    @discardableResult
    func addSpace(_ height: CGFloat) -> Self {
        let spacer = Spacer(height: height)
        contentStack.addArrangedSubview(spacer)
        return self
    }
}
