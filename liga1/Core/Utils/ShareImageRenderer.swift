//
//  ShareImageRenderer.swift
//  liga1
//
//  Renderiza una vista a `UIImage` para compartir en historias / chats.
//

import UIKit

enum ShareImageRenderer {

    /// Tamaño típico de historia de Instagram/WhatsApp (px).
    static let storySize = CGSize(width: 1080, height: 1920)

    /// Renderiza `view` a una imagen de `size` píxeles exactos (escala 1).
    /// La vista se re-dimensiona y se hace layout antes de capturar.
    static func image(of view: UIView, size: CGSize) -> UIImage {
        view.bounds = CGRect(origin: .zero, size: size)
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
