//
//  MatchesViewController.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit
import FirebaseFirestore
import FirebaseCore

class MatchesViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView()

    // MARK: - Data
    private var matches: [Match] = []                 // partidos pendientes traídos desde Firestore
    private var localMatches: [String: Match] = [:]   // copia local (por documentID)
    private var localTeams: [String: Team] = [:]      // equipos "display" (pueden ser recalculados en memoria)
    // snapshot original de equipos por partido (para calcular delta al finalizar)
    private var teamSnapshotPerMatch: [String: (local: Team, visita: Team)] = [:]

    // Firestore
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Partidos Pendientes"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchPendingMatches()
    }

    // MARK: - Setup UI
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchCell.self, forCellReuseIdentifier: "MatchCell")
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Fetch data
    private func fetchPendingMatches() {
        db.collection("matches")
            .whereField("estado", isEqualTo: Match.EstadoMatch.pendiente.rawValue)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error al obtener matches pendientes: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                self.matches = documents.compactMap { doc in
                    // intenta decodificar directamente
                    return try? doc.data(as: Match.self)
                }

                // guardamos copia local e intentamos traer equipos
                for match in self.matches {
                    let id = match.documentID()
                    self.localMatches[id] = match

                    // Traer equipos del torneo correspondiente
                    self.fetchTeam(teamId: match.equipoLocalId, torneo: match.torneo) { team in
                        if let t = team {
                            self.localTeams[match.equipoLocalId] = t
                        } else {
                            self.localTeams[match.equipoLocalId] = Team(nombre: match.equipoLocalId)
                        }
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                    self.fetchTeam(teamId: match.equipoVisitanteId, torneo: match.torneo) { team in
                        if let t = team {
                            self.localTeams[match.equipoVisitanteId] = t
                        } else {
                            self.localTeams[match.equipoVisitanteId] = Team(nombre: match.equipoVisitanteId)
                        }
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    private func fetchTeam(teamId: String, torneo: Match.Torneo, completion: @escaping (Team?) -> Void) {
        let col = torneo.rawValue // "clausura" o "apertura"
        db.collection(col).document(teamId).getDocument { snapshot, error in
            if let error = error {
                print("Error al traer team \(teamId): \(error)")
                completion(nil)
                return
            }
            guard let snap = snapshot, snap.exists else {
                completion(nil)
                return
            }
            let team = try? snap.data(as: Team.self)
            completion(team)
        }
    }

    // MARK: - Aplicar partido sobre snapshot (para mostrar en UI)
    // Crea un "display" del equipo combinando snapshot original + resultado actual del partido.
    private func applyMatchToTeams(match: Match) {
        let id = match.documentID()
        // si no existe snapshot original, creamos a partir de localTeams (o un Team vacío)
        if teamSnapshotPerMatch[id] == nil {
            let origLocal = localTeams[match.equipoLocalId] ?? Team(nombre: match.equipoLocalId)
            let origVisita = localTeams[match.equipoVisitanteId] ?? Team(nombre: match.equipoVisitanteId)
            teamSnapshotPerMatch[id] = (local: origLocal, visita: origVisita)
        }

        guard let snapshot = teamSnapshotPerMatch[id] else { return }

        var displayLocal = snapshot.local
        var displayVisita = snapshot.visita

        // sumar el partido actual (este partido) a las estadísticas del snapshot para mostrar en UI
        displayLocal.partidosJugados += 1
        displayVisita.partidosJugados += 1

        displayLocal.golesFavor += match.golesEquipoLocal
        displayLocal.golesContra += match.golesEquipoVisitante

        displayVisita.golesFavor += match.golesEquipoVisitante
        displayVisita.golesContra += match.golesEquipoLocal

        if match.golesEquipoLocal > match.golesEquipoVisitante {
            displayLocal.partidosGanados += 1
            displayLocal.puntos += 3
            displayVisita.partidosPerdidos += 1
        } else if match.golesEquipoLocal < match.golesEquipoVisitante {
            displayVisita.partidosGanados += 1
            displayVisita.puntos += 3
            displayLocal.partidosPerdidos += 1
        } else {
            displayLocal.partidosEmpatados += 1
            displayVisita.partidosEmpatados += 1
            displayLocal.puntos += 1
            displayVisita.puntos += 1
        }

        displayLocal.diferenciaGoles = displayLocal.golesFavor - displayLocal.golesContra
        displayVisita.diferenciaGoles = displayVisita.golesFavor - displayVisita.golesContra

        // actualizamos los equipos "display" usados por la UI
        localTeams[match.equipoLocalId] = displayLocal
        localTeams[match.equipoVisitanteId] = displayVisita
    }

    // MARK: - Finalizar y persistir (con transacción)
    private func finalizeMatchAndPersist(match: Match, completion: @escaping (Error?) -> Void) {
        let matchId = match.documentID()
        guard let snapshot = teamSnapshotPerMatch[matchId] else {
            completion(NSError(domain: "Matches", code: 0, userInfo: [NSLocalizedDescriptionKey: "No snapshot de equipos para este partido"]))
            return
        }

        // construir equipos finales (partiendo del snapshot original)
        var finalLocal = snapshot.local
        var finalVisita = snapshot.visita

        finalLocal.partidosJugados += 1
        finalVisita.partidosJugados += 1

        finalLocal.golesFavor += match.golesEquipoLocal
        finalLocal.golesContra += match.golesEquipoVisitante

        finalVisita.golesFavor += match.golesEquipoVisitante
        finalVisita.golesContra += match.golesEquipoLocal

        if match.golesEquipoLocal > match.golesEquipoVisitante {
            finalLocal.partidosGanados += 1
            finalVisita.partidosPerdidos += 1
            finalLocal.puntos += 3
        } else if match.golesEquipoLocal < match.golesEquipoVisitante {
            finalVisita.partidosGanados += 1
            finalLocal.partidosPerdidos += 1
            finalVisita.puntos += 3
        } else {
            finalLocal.partidosEmpatados += 1
            finalVisita.partidosEmpatados += 1
            finalLocal.puntos += 1
            finalVisita.puntos += 1
        }

        finalLocal.diferenciaGoles = finalLocal.golesFavor - finalLocal.golesContra
        finalVisita.diferenciaGoles = finalVisita.golesFavor - finalVisita.golesContra

        // deltas (final - snapshot original) para FieldValue.increment
        let deltaLocal = deltaBetween(final: finalLocal, original: snapshot.local)
        let deltaVisita = deltaBetween(final: finalVisita, original: snapshot.visita)

        let torneoCol = match.torneo.rawValue // "clausura" o "apertura"
        let localRef = db.collection(torneoCol).document(match.equipoLocalId)
        let visitaRef = db.collection(torneoCol).document(match.equipoVisitanteId)
        let matchRef = db.collection("matches").document(matchId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // actualizaciones local
            var updatesLocal: [String: Any] = [:]
            for (k, v) in deltaLocal {
                updatesLocal[k] = FieldValue.increment(Int64(v))
            }
            transaction.updateData(updatesLocal, forDocument: localRef)

            // actualizaciones visita
            var updatesVisita: [String: Any] = [:]
            for (k, v) in deltaVisita {
                updatesVisita[k] = FieldValue.increment(Int64(v))
            }
            transaction.updateData(updatesVisita, forDocument: visitaRef)

            // guardar match finalizado
            var finalMatch = match
            finalMatch.estado = .finalizado
            transaction.setData(finalMatch.toDictionary(), forDocument: matchRef)

            return nil
        }, completion: { (_, error) in
            completion(error)
        })
    }

    private func deltaBetween(final: Team, original: Team) -> [String: Int] {
        return [
            "partidosJugados": final.partidosJugados - original.partidosJugados,
            "partidosGanados": final.partidosGanados - original.partidosGanados,
            "partidosEmpatados": final.partidosEmpatados - original.partidosEmpatados,
            "partidosPerdidos": final.partidosPerdidos - original.partidosPerdidos,
            "golesFavor": final.golesFavor - original.golesFavor,
            "golesContra": final.golesContra - original.golesContra,
            "diferenciaGoles": final.diferenciaGoles - original.diferenciaGoles,
            "puntos": final.puntos - original.puntos
        ]
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource & MatchCellDelegate
extension MatchesViewController: UITableViewDelegate, UITableViewDataSource, MatchCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = matches[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchCell else {
            return UITableViewCell()
        }
        
        let localMatch = localMatches[match.documentID()] ?? match
        
        // 🔹 Construimos Team con nombre completo y logo desde assets
        let localTeam = Team(
            nombre: EquipoPeruano.obtenerNombreCompleto(paraId: localMatch.equipoLocalId),
            logo: localMatch.equipoLocalId // el campo logo es igual al nombre en assets
        )
        
        let visitaTeam = Team(
            nombre: EquipoPeruano.obtenerNombreCompleto(paraId: localMatch.equipoVisitanteId),
            logo: localMatch.equipoVisitanteId
        )
        
        cell.configure(with: localMatch, localTeam: localTeam, visitaTeam: visitaTeam)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // MARK: - MatchCellDelegate

    func didTapIniciar(match: Match) {
        let id = match.documentID()
        guard var localMatch = localMatches[id] else { return }
        localMatch.estado = .enJuego
        localMatches[id] = localMatch

        // guardamos snapshot original de equipos si no existe
        let origLocal = localTeams[localMatch.equipoLocalId] ?? Team(nombre: localMatch.equipoLocalId)
        let origVisita = localTeams[localMatch.equipoVisitanteId] ?? Team(nombre: localMatch.equipoVisitanteId)
        teamSnapshotPerMatch[id] = (local: origLocal, visita: origVisita)

        // aplicamos visualmente (ej: 0-0 inicial)
        applyMatchToTeams(match: localMatch)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didTapActualizar(match: Match) {
        let id = match.documentID()
        // actualizamos la copia local (solo en memoria)
        localMatches[id] = match
        // recalculamos display teams partiendo del snapshot original
        applyMatchToTeams(match: match)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didTapFinalizar(match: Match) {
        let id = match.documentID()
        guard let _ = localMatches[id] else { return }

        // persistir match y actualizar equipos en transacción
        finalizeMatchAndPersist(match: match) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("Error al finalizar match: \(error)")
                    // aquí podrías mostrar un alert al usuario
                    return
                }
                // si todo OK, removemos partido de pendientes y snapshots locales
                self.matches.removeAll { $0.documentID() == id }
                self.localMatches.removeValue(forKey: id)
                self.teamSnapshotPerMatch.removeValue(forKey: id)
                // opcional: actualizar localTeams re-fetch si quieres consistencia absoluta
                self.tableView.reloadData()
            }
        }
    }

    func didUpdateScore(match: Match, local: Int, visita: Int) {
        let id = match.documentID()
        // actualizamos la copia local del match
        localMatches[id] = match
        // recalculamos equipos para display
        applyMatchToTeams(match: match)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
