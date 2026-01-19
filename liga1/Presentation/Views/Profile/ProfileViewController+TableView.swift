//
//  ProfileViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].options.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let option = viewModel.sections[indexPath.section].options[indexPath.row]

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = option.title
        cell.detailTextLabel?.text = option.subtitle
        cell.imageView?.image = option.icon
        cell.accessoryType = option.action != .none ? .disclosureIndicator : .none
        cell.selectionStyle = option.action != .none ? .default : .none
        
        // Estilo destructivo para "Cerrar Sesión"
        if option.action == .logout {
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.tintColor = .systemRed
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = viewModel.sections[indexPath.section].options[indexPath.row]
        handleAction(option.action)
    }
}
