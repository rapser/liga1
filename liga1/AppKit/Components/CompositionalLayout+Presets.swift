//
//  CompositionalLayout+Presets.swift
//  liga1
//
//  Created by AppKit
//  Layouts pre-armados para UICollectionViewCompositionalLayout
//

import UIKit

// MARK: - Compositional Layout Presets

extension UICollectionViewCompositionalLayout {

    /// Lista vertical simple (similar a UITableView)
    static func list(
        appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
        headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none,
        footerMode: UICollectionLayoutListConfiguration.FooterMode = .none
    ) -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: appearance)
        config.headerMode = headerMode
        config.footerMode = footerMode
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    /// Grid de N columnas con items de tamaño uniforme
    static func grid(
        columns: Int,
        itemSpacing: CGFloat = Spacing.small,
        sectionInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: Spacing.standard, leading: Spacing.standard,
            bottom: Spacing.standard, trailing: Spacing.standard
        ),
        headerHeight: CGFloat? = nil
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let fraction: CGFloat = 1.0 / CGFloat(columns)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fraction),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: itemSpacing / 2, leading: itemSpacing / 2,
                bottom: itemSpacing / 2, trailing: itemSpacing / 2
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(fraction)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = sectionInsets

            if let headerHeight = headerHeight {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(headerHeight)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
            }

            return section
        }
    }

    /// Carrusel horizontal con items de ancho fijo
    static func carousel(
        itemWidth: CGFloat,
        itemHeight: CGFloat? = nil,
        spacing: CGFloat = Spacing.small,
        sectionInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Spacing.standard,
            bottom: 0, trailing: Spacing.standard
        )
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let heightDimension: NSCollectionLayoutDimension = itemHeight != nil
                ? .absolute(itemHeight!)
                : .fractionalHeight(1.0)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: heightDimension
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: heightDimension
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = spacing
            section.contentInsets = sectionInsets

            return section
        }
    }

    /// Layout vertical con items de alto estimado (self-sizing)
    static func verticalList(
        estimatedHeight: CGFloat = 100,
        spacing: CGFloat = Spacing.small,
        sectionInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Spacing.standard,
            bottom: 0, trailing: Spacing.standard
        )
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = sectionInsets

            return section
        }
    }
}
