//
//  Color+Extension.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit

public extension UIColor {
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

    static let libertadoresGold = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)        // #FFCC00
    static let libertadoresLightGold = UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)   // #FFE666
    static let libertadoresLighterGold = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0) // #FFF2B3
    static let sudamericanaBlue = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)        // #99CCFF
    static let relegationRed = UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)           // #FFB3B3

    // Color principal de Liga 1
    static let liga1Red = UIColor(red: 0.9, green: 0.1, blue: 0.2, alpha: 1.0)                // #E61A33 (Rojo Liga 1)
}
