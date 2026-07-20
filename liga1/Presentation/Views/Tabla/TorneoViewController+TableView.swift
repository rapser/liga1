//
//  TorneoViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit

extension TablaViewController: UITableViewDataSource, UITableViewDelegate {

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
        let isChampion = position == .campeon

        // En modo oscuro, solo colorear posiciones importantes (no las normales)
        var positionColor: UIColor? = nil
        if isDarkMode && position != .normal && !isChampion {
            positionColor = position.backgroundColor
        }

        cell.configure(with: equipo, position: indexPath.row + 1, positionColor: positionColor, isChampion: isChampion)
        cell.backgroundColor = backgroundColorForPosition(at: indexPath)
        return cell
    }
    
    private func backgroundColorForPosition(at indexPath: IndexPath) -> UIColor {
        // En modo oscuro, usar fondo uniforme sin colores de posición
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .systemBackground
        }

        let position = determinePosition(for: indexPath.row)
        // Si es campeón, no aplicar fondo amarillo a toda la celda (solo al número)
        if position == .campeon {
            return .systemBackground
        }
        return position.backgroundColor
    }
    
    private func determinePosition(for row: Int) -> TablePosition {
        let totalRows = viewModel.displayedTeams.count

        switch viewModel.selectedTorneo {
        case .acumulado:
            switch row {
            case 0, 1:
                return .libertadoresDirecta
            case 2:
                return .libertadoresFase2
            case 3:
                return .libertadoresFase1
            case 4...7:
                return .sudamericana
            case let position where position >= max(totalRows - 2, 0):
                return .descenso
            default:
                return .normal
            }

        case .apertura, .clausura:
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
