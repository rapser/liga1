//
//  UIViewController+Alert.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import UIKit

/// Extension centralizada para mostrar alertas
/// Elimina duplicación de código de alertas en múltiples ViewControllers
extension UIViewController {

    /// Muestra un error con título "Error" y el mensaje del error
    func showError(_ error: Error) {
        showAlert(
            title: "Error",
            message: error.localizedDescription,
            buttonTitle: "OK"
        )
    }

    /// Muestra un error con título y mensaje personalizados
    func showError(title: String = "Error", message: String) {
        showAlert(
            title: title,
            message: message,
            buttonTitle: "OK"
        )
    }

    /// Muestra una alerta básica con un botón
    func showAlert(
        title: String,
        message: String,
        buttonTitle: String = "OK",
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: buttonTitle,
            style: .default,
            handler: handler
        ))

        present(alert, animated: true)
    }

    /// Muestra una alerta de confirmación con dos botones
    func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Aceptar",
        cancelTitle: String = "Cancelar",
        confirmStyle: UIAlertAction.Style = .default,
        confirmHandler: @escaping (UIAlertAction) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: nil
        ))

        alert.addAction(UIAlertAction(
            title: confirmTitle,
            style: confirmStyle,
            handler: confirmHandler
        ))

        present(alert, animated: true)
    }

    /// Muestra una acción sheet (bottom sheet) con múltiples opciones
    func showActionSheet(
        title: String?,
        message: String?,
        actions: [UIAlertAction],
        sourceView: UIView? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )

        actions.forEach { alert.addAction($0) }

        alert.addAction(UIAlertAction(
            title: "Cancelar",
            style: .cancel,
            handler: nil
        ))

        // Para iPad
        if let popover = alert.popoverPresentationController,
           let sourceView = sourceView {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        present(alert, animated: true)
    }
}
