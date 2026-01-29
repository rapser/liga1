//
//  ContainerView.swift
//  liga1
//
//  Created by AppKit
//

import UIKit

// MARK: - ContainerView

/// Vista contenedora que facilita el layout entre navigation bar y tab bar
class ContainerView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Convenience Methods

    /// Adjunta la vista al safe area del view principal
    @discardableResult
    func attachToSafeArea(in view: UIView) -> Self {
        view.addSubview(self)
        fillSuperviewSafeArea()
        return self
    }

    /// Adjunta la vista entre el navigation bar y el tab bar
    @discardableResult
    func attachBetweenNavigationAndTabBar(in view: UIView, hasTabBar: Bool = true) -> Self {
        view.addSubview(self)

        prepareForAutoLayout()

        if hasTabBar {
            // Anclar desde safe area top hasta safe area bottom (respetando tab bar)
            anchor(
                top: view.safeAreaLayoutGuide.topAnchor,
                leading: view.leadingAnchor,
                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                trailing: view.trailingAnchor
            )
        } else {
            // Sin tab bar, usar todo el safe area
            fillSuperviewSafeArea()
        }

        return self
    }

    /// Adjunta la vista con padding personalizado
    @discardableResult
    func attach(in view: UIView, padding: UIEdgeInsets = .zero) -> Self {
        view.addSubview(self)
        fillSuperview(padding: padding)
        return self
    }
}

// MARK: - UIView Container Helper

extension UIView {

    /// Crea y añade un container view
    func addContainerView() -> ContainerView {
        let container = ContainerView()
        addSubview(container)
        return container
    }

    /// Crea y añade un container view con safe area
    func addContainerViewInSafeArea() -> ContainerView {
        let container = ContainerView()
        container.attachToSafeArea(in: self)
        return container
    }

    /// Crea y añade un container view entre navigation y tab bar
    func addContainerViewBetweenBars(hasTabBar: Bool = true) -> ContainerView {
        let container = ContainerView()
        container.attachBetweenNavigationAndTabBar(in: self, hasTabBar: hasTabBar)
        return container
    }
}
