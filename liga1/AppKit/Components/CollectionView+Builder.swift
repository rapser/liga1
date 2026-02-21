//
//  CollectionView+Builder.swift
//  liga1
//
//  Created by AppKit
//  Builder pattern para UICollectionView, similar a TableView+Builder
//

import UIKit

// MARK: - UICollectionView Builder Extension

extension UICollectionView {

    @discardableResult
    func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        return self
    }

    @discardableResult
    func registerHeader<T: UICollectionReusableView>(_ viewClass: T.Type) -> Self {
        register(
            viewClass,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: viewClass)
        )
        return self
    }

    @discardableResult
    func registerFooter<T: UICollectionReusableView>(_ viewClass: T.Type) -> Self {
        register(
            viewClass,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: viewClass)
        )
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
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func contentInset(_ inset: UIEdgeInsets) -> Self {
        contentInset = inset
        return self
    }
}

// MARK: - Type-safe Dequeue

extension UICollectionView {

    /// Dequeue de celda type-safe
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: cellClass),
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: cellClass))")
        }
        return cell
    }

    /// Dequeue de header type-safe
    func dequeueReusableHeader<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: viewClass),
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue header with identifier: \(String(describing: viewClass))")
        }
        return view
    }

    /// Dequeue de footer type-safe
    func dequeueReusableFooter<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: viewClass),
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue footer with identifier: \(String(describing: viewClass))")
        }
        return view
    }
}
