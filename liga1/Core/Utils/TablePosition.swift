//
//  TablePosition.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//
import UIKit

public enum TablePosition {
    case libertadoresDirecta          // Puestos 1-2
    case libertadoresFase2           // Puesto 3
    case libertadoresFase1           // Puesto 4
    case sudamericana                // Puestos 5-8
    case descenso                    // Últimos 3 puestos
    case campeon                     // Solo puesto 1 en torneos regulares
    case normal                      // Posiciones normales

    public var backgroundColor: UIColor {
        switch self {
        case .libertadoresDirecta, .campeon:
            return .libertadoresGold
        case .libertadoresFase2:
            return .libertadoresLightGold
        case .libertadoresFase1:
            return .libertadoresLighterGold
        case .sudamericana:
            return .sudamericanaBlue
        case .descenso:
            return .relegationRed
        case .normal:
            return .systemBackground
        }
    }


    public var description: String {
        switch self {
        case .libertadoresDirecta: return "Clasificado a Fase de Grupos Libertadores"
        case .libertadoresFase2: return "Clasificado a Fase 2 Libertadores"
        case .libertadoresFase1: return "Clasificado a Fase 1 Libertadores"
        case .sudamericana: return "Clasificado a Copa Sudamericana"
        case .descenso: return "Zona de descenso"
        case .campeon: return "Campeón del torneo"
        case .normal: return "Posición normal"
        }
    }
}
