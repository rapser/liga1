//
//  TableView+Builder.swift
//  liga1
//
//  Created by AppKit
//

import UIKit

// MARK: - UITableView Builder Extension

extension UITableView {

    @discardableResult
    func delegate(_ delegate: UITableViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func dataSource(_ dataSource: UITableViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    func rowHeight(_ height: CGFloat) -> Self {
        rowHeight = height
        return self
    }

    @discardableResult
    func estimatedRowHeight(_ height: CGFloat) -> Self {
        estimatedRowHeight = height
        return self
    }

    @discardableResult
    func separatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        separatorStyle = style
        return self
    }

    @discardableResult
    func separatorColor(_ color: UIColor?) -> Self {
        separatorColor = color
        return self
    }

    @discardableResult
    func separatorInset(_ inset: UIEdgeInsets) -> Self {
        separatorInset = inset
        return self
    }

    @discardableResult
    func allowsSelection(_ allows: Bool) -> Self {
        allowsSelection = allows
        return self
    }

    @discardableResult
    func allowsMultipleSelection(_ allows: Bool) -> Self {
        allowsMultipleSelection = allows
        return self
    }

    @discardableResult
    func showsVerticalScrollIndicator(_ shows: Bool) -> Self {
        showsVerticalScrollIndicator = shows
        return self
    }

    @discardableResult
    func showsHorizontalScrollIndicator(_ shows: Bool) -> Self {
        showsHorizontalScrollIndicator = shows
        return self
    }

    @discardableResult
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func contentInset(_ inset: UIEdgeInsets) -> Self {
        contentInset = inset
        return self
    }

    @discardableResult
    func tableHeaderView(_ view: UIView?) -> Self {
        tableHeaderView = view
        return self
    }

    @discardableResult
    func tableFooterView(_ view: UIView?) -> Self {
        tableFooterView = view
        return self
    }

    @discardableResult
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) -> Self {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        return self
    }

    @discardableResult
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> Self {
        register(viewClass, forHeaderFooterViewReuseIdentifier: String(describing: viewClass))
        return self
    }

    /// Remueve separadores de celdas vacías
    @discardableResult
    func removeEmptyCellSeparators() -> Self {
        tableFooterView = UIView()
        return self
    }

    /// Configura el tableView para usar Auto Layout en las celdas
    @discardableResult
    func enableAutomaticDimensions() -> Self {
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 100
        return self
    }
}

// MARK: - UITableViewCell Helper

extension UITableView {

    /// Dequeue de celda type-safe
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: cellClass))")
        }
        return cell
    }

    /// Dequeue de header/footer type-safe
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: String(describing: viewClass)) as? T else {
            fatalError("Could not dequeue header/footer view with identifier: \(String(describing: viewClass))")
        }
        return view
    }
}
