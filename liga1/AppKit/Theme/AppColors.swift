//
//  AppColors.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//  Consolidado en AppKit por AppKit
//
//  Colores semánticos de la app + colores de marca Liga 1
//

import UIKit

// MARK: - Semantic Colors

public extension UIColor {

    // MARK: - Backgrounds

    /// Fondo principal de la app: negro en modo oscuro, blanco en modo claro.
    static let appBackground: UIColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .black : .white
    }

    /// Fondo secundario (cards, agrupados): negro muy suave en oscuro, blanco en modo claro.
    static let appSecondaryBackground: UIColor = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(white: 0.11, alpha: 1)
        }
        return .white
    }

    // MARK: - Semantic Actions

    /// Color de acento principal de la app
    static let appTint: UIColor = liga1Red

    /// Color para acciones destructivas
    static let appDestructive: UIColor = .systemRed

    /// Color para estados de éxito
    static let appSuccess: UIColor = .systemGreen

    /// Color para estados de advertencia
    static let appWarning: UIColor = .systemOrange

    // MARK: - Brand Colors (Liga 1)

    /// Color principal de Liga 1
    static let liga1Red = UIColor(red: 0.9, green: 0.1, blue: 0.2, alpha: 1.0)  // #E61A33

    /// Barra comparativa de estadísticas: equipo local (izquierda), estilo teal.
    static let statComparisonLocal: UIColor = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0.22, green: 0.62, blue: 0.56, alpha: 1)
        }
        return UIColor(red: 0.12, green: 0.48, blue: 0.44, alpha: 1)
    }

    /// Barra comparativa de estadísticas: equipo visitante (derecha).
    static let statComparisonVisitante: UIColor = liga1Red

    // MARK: - Competition Colors

    static let libertadoresGold = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)        // #FFCC00
    static let libertadoresLightGold = UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)   // #FFE666
    static let libertadoresLighterGold = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0) // #FFF2B3
    static let sudamericanaBlue = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)        // #99CCFF
    static let relegationRed = UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)           // #FFB3B3
}
