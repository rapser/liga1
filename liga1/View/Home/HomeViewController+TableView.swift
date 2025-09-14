//
//  HomeViewController+TableView.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let match = matches[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }

        // Aquí deberías cargar tus logos según el equipo
        let logoLocal = UIImage(named: match.equipoLocalId)
        let logoVisitante = UIImage(named: match.equipoVisitanteId)
        
        cell.configure(with: match, logoLocal: logoLocal, logoVisitante: logoVisitante)
        return cell
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let fechaLabel = UILabel()
        fechaLabel.font = .boldSystemFont(ofSize: 18)
        fechaLabel.textColor = .black
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        fechaLabel.text = "Hoy \(formatter.string(from: Date()))"
        
        let torneoLabel = UILabel()
        torneoLabel.font = .systemFont(ofSize: 14)
        torneoLabel.textColor = .darkGray
        torneoLabel.translatesAutoresizingMaskIntoConstraints = false
        torneoLabel.text = "Liga 1 - Clausura"
        
        view.addSubview(fechaLabel)
        view.addSubview(torneoLabel)
        
        NSLayoutConstraint.activate([
            fechaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fechaLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            
            torneoLabel.leadingAnchor.constraint(equalTo: fechaLabel.leadingAnchor),
            torneoLabel.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 4),
            torneoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
