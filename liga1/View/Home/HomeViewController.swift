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
    var favoriteMatchIds: Set<String> = []
    var favoritesListener: ListenerRegistration?

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

        listenToFavorites()
        fetchMatchesForToday()
    }

    deinit {
        favoritesListener?.remove()
    }
    
    // MARK: - Firestore
    private func listenToFavorites() {
        // Solo escuchar favoritos si el usuario está autenticado
        favoritesListener = FavoritesManager.shared.listenToFavorites { [weak self] favoriteIds in
            guard let self = self else { return }
            self.favoriteMatchIds = Set(favoriteIds)
            self.updateMatchesFavoriteStatus()
        }
    }

    private func updateMatchesFavoriteStatus() {
        // Solo actualizar si hay partidos cargados
        guard !matches.isEmpty else { return }

        for index in matches.indices {
            if let matchId = matches[index].id {
                matches[index].isFavorite = favoriteMatchIds.contains(matchId)
            }
        }
        tableView.reloadData()
    }

    func fetchMatchesForToday() {
        let db = Firestore.firestore()

        // DEBUG: Primero ver qué hay en la colección
        db.collection("matches").limit(to: 3).getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                print("🔍 DEBUG - Primeros 3 documentos en 'matches':")
                for doc in docs {
                    print("  - ID: \(doc.documentID)")
                    print("    Data: \(doc.data())")
                }
            }
        }

        // Cargar todos los partidos de la jornada 8 del torneo Clausura
        db.collection("matches")
            .whereField("jornada", isEqualTo: 8)
            .whereField("torneo", isEqualTo: "clausura")
            .order(by: "fecha")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching matches: \(error)")
                    print("❌ Error localizedDescription: \(error.localizedDescription)")
                    return
                }

                print("📦 Total documentos encontrados: \(snapshot?.documents.count ?? 0)")

                guard let documents = snapshot?.documents else {
                    print("⚠️ No hay documentos en snapshot")
                    return
                }

                self.matches = documents.compactMap { doc in
                    print("📄 Procesando doc: \(doc.documentID)")
                    return try? doc.data(as: Match.self)
                }

                print("✅ Partidos cargados: \(self.matches.count)")
                self.updateMatchesFavoriteStatus()

                // Asegurar que la tabla se actualice aunque no haya favoritos
                if self.favoriteMatchIds.isEmpty {
                    self.tableView.reloadData()
                }
            }
    }

}
