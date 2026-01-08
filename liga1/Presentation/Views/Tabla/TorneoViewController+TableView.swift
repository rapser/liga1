//
//  TorneoViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit

extension TorneoViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedTeams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EquipoCell", for: indexPath) as? EquipoTableViewCell else {
            return UITableViewCell()
        }

        let equipo = viewModel.displayedTeams[indexPath.row]

        let position = determinePosition(for: indexPath.row)
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

        // En modo oscuro, solo colorear posiciones importantes (no las normales)
        var positionColor: UIColor? = nil
        if isDarkMode && position != .normal {
            positionColor = position.backgroundColor
        }

        cell.configure(with: equipo, position: indexPath.row + 1, positionColor: positionColor)
        cell.backgroundColor = backgroundColorForPosition(at: indexPath)
        return cell
    }
    
    private func backgroundColorForPosition(at indexPath: IndexPath) -> UIColor {
        // En modo oscuro, usar fondo uniforme sin colores de posición
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .systemBackground
        }

        let position = determinePosition(for: indexPath.row)
        return position.backgroundColor
    }
    
    private func determinePosition(for row: Int) -> TablePosition {
        let totalRows = viewModel.displayedTeams.count
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
