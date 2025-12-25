//
//  HomeViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    var matches: [Match] = []
    var favoriteMatchIds: Set<String> = []
    var favoritesListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
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

        // Cargar todos los partidos de la jornada 8 del torneo Clausura
        // Usar getDocuments(source: .cache) primero para carga instantánea
        db.collection("matches")
            .whereField("jornada", isEqualTo: 8)
            .whereField("torneo", isEqualTo: "clausura")
            .order(by: "fecha")
            .getDocuments(source: .cache) { [weak self] snapshot, error in
                guard let self = self else { return }

                // Si hay datos en caché, cargarlos inmediatamente
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.matches = documents.compactMap { doc in
                        return try? doc.data(as: Match.self)
                    }
                    print("✅ Partidos cargados desde caché: \(self.matches.count)")
                    self.updateMatchesFavoriteStatus()

                    // Asegurar que la tabla se actualice aunque no haya favoritos
                    if self.favoriteMatchIds.isEmpty {
                        self.tableView.reloadData()
                    }
                }

                // Luego, consultar el servidor en segundo plano para actualizaciones
                db.collection("matches")
                    .whereField("jornada", isEqualTo: 8)
                    .whereField("torneo", isEqualTo: "clausura")
                    .order(by: "fecha")
                    .getDocuments(source: .server) { [weak self] serverSnapshot, serverError in
                        guard let self = self else { return }

                        if let serverError = serverError {
                            print("⚠️ Error al actualizar desde servidor: \(serverError.localizedDescription)")
                            // Si no hay conexión, no pasa nada, ya tenemos datos del caché
                            return
                        }

                        guard let serverDocuments = serverSnapshot?.documents, !serverDocuments.isEmpty else {
                            return
                        }

                        let serverMatches = serverDocuments.compactMap { doc in
                            return try? doc.data(as: Match.self)
                        }

                        // Solo actualizar si hay cambios
                        if serverMatches.count != self.matches.count {
                            self.matches = serverMatches
                            print("🔄 Partidos actualizados desde servidor: \(self.matches.count)")
                            self.updateMatchesFavoriteStatus()

                            if self.favoriteMatchIds.isEmpty {
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
    }

}
