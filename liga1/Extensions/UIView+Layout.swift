//
//  UIView+Layout.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import UIKit

// MARK: - Spacing Presets
enum Spacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let standard: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - UIView Layout Extensions
extension UIView {

    // MARK: - Preparation

    /// Prepara la vista para AutoLayout programático
    @discardableResult
    func prepareForAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    /// Agrega la vista como subview y la prepara para AutoLayout
    @discardableResult
    func addTo(_ superview: UIView) -> Self {
        superview.addSubview(self)
        return prepareForAutoLayout()
    }

    // MARK: - Fill Superview

    /// Llena completamente el superview
    @discardableResult
    func fillSuperview(padding: UIEdgeInsets = .zero) -> Self {
        guard let superview = superview else { return self }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom)
        ])
        return self
    }

    /// Llena el superview respetando el safe area
    @discardableResult
    func fillSuperviewSafeArea(padding: UIEdgeInsets = .zero) -> Self {
        guard let superview = superview else { return self }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: padding.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom)
        ])
        return self
    }

    // MARK: - Centering

    /// Centra la vista en su superview
    @discardableResult
    func centerInSuperview(offset: CGPoint = .zero) -> Self {
        guard let superview = superview else { return self }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offset.y)
        ])
        return self
    }

    /// Centra horizontalmente en el superview
    @discardableResult
    func centerX(offset: CGFloat = 0) -> Self {
        guard let superview = superview else { return self }
        centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offset).isActive = true
        return self
    }

    /// Centra verticalmente en el superview
    @discardableResult
    func centerY(offset: CGFloat = 0) -> Self {
        guard let superview = superview else { return self }
        centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offset).isActive = true
        return self
    }

    // MARK: - Size

    /// Establece el tamaño de la vista
    @discardableResult
    func size(_ size: CGSize) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
        return self
    }

    /// Establece el ancho de la vista
    @discardableResult
    func width(_ width: CGFloat) -> Self {
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }

    /// Establece el alto de la vista
    @discardableResult
    func height(_ height: CGFloat) -> Self {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }

    /// Establece un tamaño cuadrado
    @discardableResult
    func square(_ size: CGFloat) -> Self {
        return self.size(CGSize(width: size, height: size))
    }

    /// Hace que el ancho sea igual al alto
    @discardableResult
    func aspectRatioSquare() -> Self {
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        return self
    }

    // MARK: - Pinning

    /// Pin al top del superview o safe area
    @discardableResult
    func pinTop(to anchor: NSLayoutYAxisAnchor? = nil, constant: CGFloat = 0, useSafeArea: Bool = false) -> Self {
        guard let superview = superview else { return self }
        let targetAnchor = anchor ?? (useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor)
        topAnchor.constraint(equalTo: targetAnchor, constant: constant).isActive = true
        return self
    }

    /// Pin al bottom del superview o safe area
    @discardableResult
    func pinBottom(to anchor: NSLayoutYAxisAnchor? = nil, constant: CGFloat = 0, useSafeArea: Bool = false) -> Self {
        guard let superview = superview else { return self }
        let targetAnchor = anchor ?? (useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor)
        bottomAnchor.constraint(equalTo: targetAnchor, constant: -constant).isActive = true
        return self
    }

    /// Pin al leading del superview
    @discardableResult
    func pinLeading(to anchor: NSLayoutXAxisAnchor? = nil, constant: CGFloat = 0) -> Self {
        guard let superview = superview else { return self }
        let targetAnchor = anchor ?? superview.leadingAnchor
        leadingAnchor.constraint(equalTo: targetAnchor, constant: constant).isActive = true
        return self
    }

    /// Pin al trailing del superview
    @discardableResult
    func pinTrailing(to anchor: NSLayoutXAxisAnchor? = nil, constant: CGFloat = 0) -> Self {
        guard let superview = superview else { return self }
        let targetAnchor = anchor ?? superview.trailingAnchor
        trailingAnchor.constraint(equalTo: targetAnchor, constant: -constant).isActive = true
        return self
    }

    /// Pin horizontalmente (leading y trailing)
    @discardableResult
    func pinHorizontal(padding: CGFloat = 0) -> Self {
        return pinLeading(constant: padding).pinTrailing(constant: padding)
    }

    /// Pin verticalmente (top y bottom)
    @discardableResult
    func pinVertical(padding: CGFloat = 0, useSafeArea: Bool = false) -> Self {
        return pinTop(constant: padding, useSafeArea: useSafeArea)
            .pinBottom(constant: padding, useSafeArea: useSafeArea)
    }

    // MARK: - Style Helpers

    /// Establece el backgroundColor
    @discardableResult
    func background(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    /// Establece el corner radius
    @discardableResult
    func corner(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        return self
    }

    /// Establece clipsToBounds
    @discardableResult
    func clip(_ clips: Bool = true) -> Self {
        clipsToBounds = clips
        return self
    }

    /// Establece el border
    @discardableResult
    func border(width: CGFloat, color: UIColor) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self
    }

    /// Oculta o muestra la vista
    @discardableResult
    func hidden(_ isHidden: Bool = true) -> Self {
        self.isHidden = isHidden
        return self
    }
}

// MARK: - UILabel Extensions
extension UILabel {

    @discardableResult
    func text(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func alignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }

    @discardableResult
    func lines(_ numberOfLines: Int) -> Self {
        self.numberOfLines = numberOfLines
        return self
    }
}

// MARK: - UIButton Extensions
extension UIButton {

    @discardableResult
    func title(_ title: String?, for state: UIControl.State = .normal) -> Self {
        setTitle(title, for: state)
        return self
    }

    @discardableResult
    func titleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
}

// MARK: - UIImageView Extensions
extension UIImageView {

    @discardableResult
    func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode
        return self
    }

    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}

// MARK: - UITextField Extensions
extension UITextField {

    @discardableResult
    func placeholder(_ text: String?) -> Self {
        placeholder = text
        return self
    }

    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func borderStyle(_ style: UITextField.BorderStyle) -> Self {
        borderStyle = style
        return self
    }

    @discardableResult
    func leftPadding(_ padding: CGFloat) -> Self {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
        leftViewMode = .always
        return self
    }
}
