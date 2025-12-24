//
//  HomeViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    var matches: [Match] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        fetchMatchesForToday()
    }
    
    // MARK: - Firestore
    func fetchMatchesForToday() {
        let db = Firestore.firestore()

        // Cargar todos los partidos de la jornada 8 del torneo Clausura
        db.collection("matches")
            .whereField("jornada", isEqualTo: 8)
            .whereField("torneo", isEqualTo: "clausura")
            .order(by: "fecha")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching matches: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.matches = documents.compactMap { doc in
                    try? doc.data(as: Match.self)
                }
                self.tableView.reloadData()
            }
    }
    
}
