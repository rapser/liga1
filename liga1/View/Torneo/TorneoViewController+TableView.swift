//
//  TorneoViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit

enum TorneoType {
    case apertura
    case clausura
    case acumulado
}

enum TablePosition {
    case libertadoresDirecta          // Puestos 1-2
    case libertadoresFase2           // Puesto 3
    case libertadoresFase1           // Puesto 4
    case sudamericana                // Puestos 5-8
    case descenso                    // Últimos 3 puestos
    case campeon                     // Solo puesto 1 en torneos regulares
    case normal                      // Posiciones normales
    
    var backgroundColor: UIColor {
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
            return .white
        }
    }
    
    var description: String {
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

extension TorneoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equiposMostrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EquipoCell", for: indexPath) as! EquipoTableViewCell
        let equipo = equiposMostrados[indexPath.row]
        
        cell.configure(with: equipo)
        cell.backgroundColor = backgroundColorForPosition(at: indexPath)
        return cell
    }
    
    private func backgroundColorForPosition(at indexPath: IndexPath) -> UIColor {
        let position = determinePosition(for: indexPath.row)
        return position.backgroundColor
    }
    
    private func determinePosition(for row: Int) -> TablePosition {
        let totalRows = equiposMostrados.count
        
        switch segmentedControl.selectedSegmentIndex {
        case 2: // Acumulado
            switch row {
            case 0, 1:    // Puestos 1-2: Libertadores Directa
                return .libertadoresDirecta
            case 2:       // Puesto 3: Libertadores Fase 2
                return .libertadoresFase2
            case 3:       // Puesto 4: Libertadores Fase 1
                return .libertadoresFase1
            case 4...7:   // Puestos 5-8: Sudamericana
                return .sudamericana
            case let x where x >= totalRows - 3: // Últimos 3: Descenso
                return .descenso
            default:      // Resto de posiciones
                return .normal
            }
            
        default: // Apertura o Clausura (torneos regulares)
            return row == 0 ? .campeon : .normal
        }
    }
    
}
