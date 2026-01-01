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

    // Estructura para agrupar partidos por jornada
    struct JornadaSection {
        let jornadaId: String      // Ej: "clausura_01"
        let numero: Int            // Número de jornada
        let torneo: String         // Nombre del torneo
        var matches: [Match]       // var para poder actualizar isFavorite
    }
    var jornadaSections: [JornadaSection] = []

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
        fetchActiveJornadas()
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
        // Actualizar favoritos en todas las secciones
        for sectionIndex in jornadaSections.indices {
            for matchIndex in jornadaSections[sectionIndex].matches.indices {
                if let matchId = jornadaSections[sectionIndex].matches[matchIndex].id {
                    let fullMatchId = "\(jornadaSections[sectionIndex].jornadaId)_\(matchId)"
                    jornadaSections[sectionIndex].matches[matchIndex].isFavorite = favoriteMatchIds.contains(fullMatchId)
                }
            }
        }

        tableView.reloadData()
    }

    // Este método ya no es necesario porque construimos las secciones directamente al cargar

    func fetchActiveJornadas() {
        let db = Firestore.firestore()

        // 1. Consultar jornadas con mostrar = true
        db.collection("jornadas")
            .whereField("mostrar", isEqualTo: true)
            .order(by: "fechaInicio", descending: true)
            .getDocuments(source: .cache) { [weak self] snapshot, error in
                guard let self = self else { return }

                // Cargar desde caché primero
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.loadMatchesForJornadas(documents: documents, fromCache: true)
                }

                // Luego actualizar desde servidor
                db.collection("jornadas")
                    .whereField("mostrar", isEqualTo: true)
                    .order(by: "fechaInicio", descending: true)
                    .getDocuments(source: .server) { [weak self] serverSnapshot, serverError in
                        guard let self = self else { return }

                        if let serverError = serverError {
                            print("⚠️ Error al actualizar jornadas desde servidor: \(serverError.localizedDescription)")
                            return
                        }

                        guard let serverDocuments = serverSnapshot?.documents, !serverDocuments.isEmpty else {
                            return
                        }

                        self.loadMatchesForJornadas(documents: serverDocuments, fromCache: false)
                    }
            }
    }

    private func loadMatchesForJornadas(documents: [QueryDocumentSnapshot], fromCache: Bool) {
        let db = Firestore.firestore()
        let jornadas = documents.compactMap { try? $0.data(as: Jornada.self) }

        guard !jornadas.isEmpty else { return }

        var tempSections: [JornadaSection] = []
        let group = DispatchGroup()

        // 2. Para cada jornada, cargar sus partidos
        for jornada in jornadas {
            guard let jornadaId = jornada.id,
                  let numero = jornada.numero,
                  let torneo = jornada.torneo else { continue }

            group.enter()

            let source: FirestoreSource = fromCache ? .cache : .server

            db.collection("jornadas")
                .document(jornadaId)
                .collection("matches")
                .order(by: "fecha")
                .getDocuments(source: source) { snapshot, error in
                    defer { group.leave() }

                    if let error = error {
                        print("⚠️ Error cargando partidos de \(jornadaId): \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        return
                    }

                    var matches = documents.compactMap { doc -> Match? in
                        var match = try? doc.data(as: Match.self)
                        match?.jornadaNumero = numero
                        match?.torneoNombre = torneo
                        return match
                    }

                    // Actualizar favoritos
                    for index in matches.indices {
                        if let matchId = matches[index].id {
                            let fullMatchId = "\(jornadaId)_\(matchId)"
                            matches[index].isFavorite = self.favoriteMatchIds.contains(fullMatchId)
                        }
                    }

                    let section = JornadaSection(
                        jornadaId: jornadaId,
                        numero: numero,
                        torneo: torneo,
                        matches: matches
                    )

                    tempSections.append(section)
                }
        }

        // 3. Cuando todas las jornadas terminen de cargar, actualizar UI
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            // Ordenar secciones por número de jornada descendente
            self.jornadaSections = tempSections.sorted { $0.numero > $1.numero }

            self.tableView.reloadData()

            let source = fromCache ? "caché" : "servidor"
            print("✅ Cargadas \(self.jornadaSections.count) jornadas desde \(source)")
        }
    }

}
