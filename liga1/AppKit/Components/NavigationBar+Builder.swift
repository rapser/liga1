//
//  NavigationBar+Builder.swift
//  liga1
//
//  Created by AppKit
//

import UIKit

// MARK: - UIViewController Navigation Bar Extension

extension UIViewController {

    /// Configurador de Navigation Bar con builder pattern
    @discardableResult
    func setupNavigationBar() -> NavigationBarConfigurator {
        return NavigationBarConfigurator(viewController: self)
    }
}

// MARK: - NavigationBarConfigurator

class NavigationBarConfigurator {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    /// Establece el título del navigation bar
    @discardableResult
    func title(_ title: String) -> Self {
        viewController?.title = title
        return self
    }

    /// Habilita/deshabilita títulos grandes
    @discardableResult
    func prefersLargeTitles(_ prefers: Bool) -> Self {
        viewController?.navigationController?.navigationBar.prefersLargeTitles = prefers
        return self
    }

    /// Establece el modo de título grande (always, automatic, never)
    @discardableResult
    func largeTitleDisplayMode(_ mode: UINavigationItem.LargeTitleDisplayMode) -> Self {
        viewController?.navigationItem.largeTitleDisplayMode = mode
        return self
    }

    /// Añade un botón izquierdo
    @discardableResult
    func leftBarButton(
        title: String? = nil,
        image: UIImage? = nil,
        systemImage: String? = nil,
        target: Any?,
        action: Selector
    ) -> Self {
        let button: UIBarButtonItem
        if let title = title {
            button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        } else if let systemImage = systemImage {
            button = UIBarButtonItem(image: UIImage(systemName: systemImage), style: .plain, target: target, action: action)
        } else if let image = image {
            button = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        } else {
            button = UIBarButtonItem(title: "", style: .plain, target: target, action: action)
        }
        viewController?.navigationItem.leftBarButtonItem = button
        return self
    }

    /// Añade un botón derecho
    @discardableResult
    func rightBarButton(
        title: String? = nil,
        image: UIImage? = nil,
        systemImage: String? = nil,
        target: Any?,
        action: Selector,
        tintColor: UIColor? = nil
    ) -> Self {
        let button: UIBarButtonItem
        if let title = title {
            button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        } else if let systemImage = systemImage {
            button = UIBarButtonItem(image: UIImage(systemName: systemImage), style: .plain, target: target, action: action)
        } else if let image = image {
            button = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        } else {
            button = UIBarButtonItem(title: "", style: .plain, target: target, action: action)
        }

        if let tintColor = tintColor {
            button.tintColor = tintColor
        }

        viewController?.navigationItem.rightBarButtonItem = button
        return self
    }

    /// Añade múltiples botones a la derecha
    @discardableResult
    func rightBarButtons(_ buttons: [UIBarButtonItem]) -> Self {
        viewController?.navigationItem.rightBarButtonItems = buttons
        return self
    }

    /// Añade múltiples botones a la izquierda
    @discardableResult
    func leftBarButtons(_ buttons: [UIBarButtonItem]) -> Self {
        viewController?.navigationItem.leftBarButtonItems = buttons
        return self
    }

    /// Oculta el botón de back
    @discardableResult
    func hidesBackButton(_ hides: Bool = true) -> Self {
        viewController?.navigationItem.hidesBackButton = hides
        return self
    }

    /// Personaliza el botón de back
    @discardableResult
    func backButtonTitle(_ title: String?) -> Self {
        viewController?.navigationItem.backButtonTitle = title
        return self
    }

    /// Oculta la barra de navegación
    @discardableResult
    func hideNavigationBar(_ hide: Bool = true, animated: Bool = false) -> Self {
        viewController?.navigationController?.setNavigationBarHidden(hide, animated: animated)
        return self
    }

    /// Establece el color de fondo del navigation bar
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color

        viewController?.navigationController?.navigationBar.standardAppearance = appearance
        viewController?.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        viewController?.navigationController?.navigationBar.compactAppearance = appearance

        return self
    }

    /// Establece el color del texto del título
    @discardableResult
    func titleColor(_ color: UIColor) -> Self {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: color]
        appearance.largeTitleTextAttributes = [.foregroundColor: color]

        viewController?.navigationController?.navigationBar.standardAppearance = appearance
        viewController?.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        return self
    }

    /// Hace el navigation bar transparente
    @discardableResult
    func transparent() -> Self {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        viewController?.navigationController?.navigationBar.standardAppearance = appearance
        viewController?.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        return self
    }

    /// Establece el tint color del navigation bar (color de botones)
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        viewController?.navigationController?.navigationBar.tintColor = color
        return self
    }

    /// Añade un prompt (texto adicional arriba del título)
    @discardableResult
    func prompt(_ text: String?) -> Self {
        viewController?.navigationItem.prompt = text
        return self
    }
}
