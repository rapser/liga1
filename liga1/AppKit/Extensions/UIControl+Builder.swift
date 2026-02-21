//
//  UIControl+Builder.swift
//  liga1
//
//  Created by AppKit
//  Builder pattern para UISwitch, UISegmentedControl, UISlider
//

import UIKit

// MARK: - UISwitch Builder

extension UISwitch {

    @discardableResult
    func isOn(_ on: Bool) -> Self {
        self.isOn = on
        return self
    }

    @discardableResult
    func onTintColor(_ color: UIColor) -> Self {
        self.onTintColor = color
        return self
    }

    @discardableResult
    func thumbTintColor(_ color: UIColor) -> Self {
        self.thumbTintColor = color
        return self
    }
}

// MARK: - UISegmentedControl Builder

extension UISegmentedControl {

    @discardableResult
    func selectedIndex(_ index: Int) -> Self {
        selectedSegmentIndex = index
        return self
    }

    @discardableResult
    func selectedTintColor(_ color: UIColor) -> Self {
        selectedSegmentTintColor = color
        return self
    }

    @discardableResult
    func normalTextAttributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        setTitleTextAttributes(attributes, for: .normal)
        return self
    }

    @discardableResult
    func selectedTextAttributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        setTitleTextAttributes(attributes, for: .selected)
        return self
    }
}

// MARK: - UISlider Builder

extension UISlider {

    @discardableResult
    func value(_ value: Float) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    func range(min: Float, max: Float) -> Self {
        minimumValue = min
        maximumValue = max
        return self
    }

    @discardableResult
    func minimumTrackTintColor(_ color: UIColor) -> Self {
        self.minimumTrackTintColor = color
        return self
    }

    @discardableResult
    func maximumTrackTintColor(_ color: UIColor) -> Self {
        self.maximumTrackTintColor = color
        return self
    }

    @discardableResult
    func thumbTintColor(_ color: UIColor) -> Self {
        self.thumbTintColor = color
        return self
    }
}

// MARK: - UIControl Target Helper

extension UIControl {

    @discardableResult
    func onTap(_ target: Any?, action: Selector) -> Self {
        addTarget(target, action: action, for: .touchUpInside)
        return self
    }

    @discardableResult
    func onValueChanged(_ target: Any?, action: Selector) -> Self {
        addTarget(target, action: action, for: .valueChanged)
        return self
    }
}
