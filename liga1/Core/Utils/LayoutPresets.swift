//
//  LayoutPresets.swift
//  liga1
//
//  Created by Miguel Tomairo on 01/01/26.
//
//  Compatibilidad: LayoutPresets ahora es un typealias de ComponentPresets.
//  Los métodos de layout (configureTableView, setupEmptyState, etc.) se mantienen
//  como extensión para no romper código existente.
//

import UIKit

// MARK: - Backward Compatibility

/// LayoutPresets es ahora un alias de ComponentPresets (en AppKit/Presets/).
/// Los métodos de creación de componentes viven en ComponentPresets.
/// Los métodos de layout se mantienen aquí como extensión.
public typealias LayoutPresets = ComponentPresets

// MARK: - Layout Helpers Extension

extension ComponentPresets {

    // MARK: - TableView Layout

    /// Configura un TableView con valores estándar y lo posiciona en el superview
    public static func configureTableView(
        _ tableView: UITableView,
        in superview: UIView,
        delegate: UITableViewDelegate? = nil,
        dataSource: UITableViewDataSource? = nil
    ) {
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = delegate
        tableView.dataSource = dataSource

        superview.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }

    /// Configura un TableView debajo de un control superior
    public static func configureTableViewBelow(
        _ tableView: UITableView,
        topView: UIView,
        in superview: UIView,
        spacing: CGFloat = Spacing.tiny,
        delegate: UITableViewDelegate? = nil,
        dataSource: UITableViewDataSource? = nil
    ) {
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        tableView.sectionHeaderTopPadding = 0
        tableView.delegate = delegate
        tableView.dataSource = dataSource

        superview.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: spacing),
            tableView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Empty State Layout

    /// Configura un empty state centrado con label
    public static func setupEmptyState(
        label: UILabel,
        in superview: UIView,
        horizontalPadding: CGFloat = 40
    ) {
        superview.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding)
        ])
    }

    // MARK: - Segmented Control

    /// Configura un segmented control con estilo estándar
    public static func configureSegmentedControl(
        _ segmentedControl: UISegmentedControl,
        in superview: UIView,
        topOffset: CGFloat = Spacing.standard,
        horizontalPadding: CGFloat = Spacing.standard,
        selectedColor: UIColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
    ) {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = selectedColor
        segmentedControl.backgroundColor = .systemBackground

        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]

        segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)

        superview.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: topOffset),
            segmentedControl.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
            segmentedControl.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
