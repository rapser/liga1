//
//  AppTheme.swift
//  liga1
//
//  Created by AppKit
//  Sistema de theming centralizado para consistencia visual
//

import UIKit

// MARK: - AppTheme

struct AppTheme {

    // MARK: - Typography

    static let largeTitle: UIFont = .systemFont(ofSize: 28, weight: .bold)
    static let title1: UIFont = .systemFont(ofSize: 24, weight: .bold)
    static let title2: UIFont = .systemFont(ofSize: 20, weight: .bold)
    static let title3: UIFont = .systemFont(ofSize: 18, weight: .bold)
    static let headline: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    static let body: UIFont = .systemFont(ofSize: 16, weight: .regular)
    static let callout: UIFont = .systemFont(ofSize: 15, weight: .regular)
    static let subheadline: UIFont = .systemFont(ofSize: 14, weight: .regular)
    static let footnote: UIFont = .systemFont(ofSize: 13, weight: .regular)
    static let caption1: UIFont = .systemFont(ofSize: 12, weight: .regular)
    static let caption2: UIFont = .systemFont(ofSize: 11, weight: .regular)

    // MARK: - Corner Radius

    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    // MARK: - Heights

    struct Heights {
        static let button: CGFloat = 52
        static let textField: CGFloat = 52
        static let cellMin: CGFloat = 44
        static let navigationBar: CGFloat = 44
        static let tabBar: CGFloat = 49
        static let segmentedControl: CGFloat = 30
    }

    // MARK: - Icon Sizes

    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let extraLarge: CGFloat = 48
    }

    // MARK: - Shadows

    struct Shadow {
        let color: UIColor
        let opacity: Float
        let offset: CGSize
        let radius: CGFloat

        static let light = Shadow(
            color: .black,
            opacity: 0.08,
            offset: CGSize(width: 0, height: 2),
            radius: 4
        )

        static let medium = Shadow(
            color: .black,
            opacity: 0.12,
            offset: CGSize(width: 0, height: 4),
            radius: 8
        )

        func apply(to view: UIView) {
            view.layer.shadowColor = color.cgColor
            view.layer.shadowOpacity = opacity
            view.layer.shadowOffset = offset
            view.layer.shadowRadius = radius
        }
    }
}

// MARK: - UIView Shadow Extension

extension UIView {

    @discardableResult
    func shadow(_ shadow: AppTheme.Shadow) -> Self {
        shadow.apply(to: self)
        return self
    }
}
