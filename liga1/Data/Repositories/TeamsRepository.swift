//
//  TeamsRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo TeamsRepositoryProtocol
class TeamsRepository: TeamsRepositoryProtocol {

    private let database: DatabaseProtocol

    /// Un listener por colección, compartido por todos los suscriptores.
    /// `nil` en el subject = todavía sin snapshot (evita pintar una tabla vacía).
    private var teamSubjects: [TorneoType: CurrentValueSubject<[Team]?, Never>] = [:]
    private var teamListeners: [TorneoType: ListenerRegistration] = [:]
    private let sanctionsSubject = CurrentValueSubject<[PointSanction]?, Never>(nil)
    private var sanctionsListener: ListenerRegistration?
    private let lock = NSLock()

    init(database: DatabaseProtocol) {
        self.database = database
    }

    deinit {
        teamListeners.values.forEach { $0.remove() }
        sanctionsListener?.remove()
    }

    private var db: Firestore {
        database.db
    }

    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        return Future<[Team], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "TeamsRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let query = self.db.collection(torneo.rawValue)
                .order(by: FirestoreConstants.TeamField.points, descending: true)

            // Intenta obtener la versión vigente del servidor y conserva el
            // fallback offline de Firestore. El dato fresco sí llega al caller.
            query.getDocuments(source: .default) { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { promise(.failure(error)); return }
                guard let docs = snapshot?.documents else { promise(.success([])); return }
                promise(.success(self.buildTeams(from: docs)))
            }
        }
        .eraseToAnyPublisher()
    }

    func observeTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Never> {
        lock.lock()
        let subject = teamSubjects[torneo] ?? CurrentValueSubject<[Team]?, Never>(nil)
        teamSubjects[torneo] = subject
        let shouldStart = teamListeners[torneo] == nil
        lock.unlock()

        if shouldStart {
            let listener = db.collection(torneo.rawValue)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }
                    guard let documents = snapshot?.documents, error == nil else {
                        // Un listener caído se descarta para que la próxima
                        // suscripción vuelva a intentarlo.
                        self.lock.lock()
                        self.teamListeners[torneo]?.remove()
                        self.teamListeners.removeValue(forKey: torneo)
                        self.lock.unlock()
                        return
                    }
                    subject.send(self.buildTeams(from: documents))
                }
            lock.lock()
            teamListeners[torneo] = listener
            lock.unlock()
        }

        return subject.compactMap { $0 }.eraseToAnyPublisher()
    }

    func observePointSanctions() -> AnyPublisher<[PointSanction], Never> {
        lock.lock()
        let shouldStart = sanctionsListener == nil
        lock.unlock()

        if shouldStart {
            let listener = db.collection(FirestoreConstants.Collection.teams)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }
                    guard let documents = snapshot?.documents, error == nil else {
                        // Sin sanciones la tabla se muestra igual; se reintenta luego.
                        self.lock.lock()
                        self.sanctionsListener?.remove()
                        self.sanctionsListener = nil
                        self.lock.unlock()
                        if self.sanctionsSubject.value == nil { self.sanctionsSubject.send([]) }
                        return
                    }
                    self.sanctionsSubject.send(documents.flatMap {
                        Self.sanctions(from: $0.data(), teamCode: $0.documentID)
                    })
                }
            lock.lock()
            sanctionsListener = listener
            lock.unlock()
        }

        return sanctionsSubject.compactMap { $0 }.eraseToAnyPublisher()
    }

    func invalidateCache(for torneo: TorneoType?) {
        // La caché del SDK de Firestore se gestiona internamente; no hay estado en memoria aquí.
    }

    static func sanctions(from data: [String: Any], teamCode: String) -> [PointSanction] {
        let raw = data[FirestoreConstants.TeamMasterField.sanctions] as? [[String: Any]] ?? []
        return raw.compactMap { item in
            guard let points = (item[FirestoreConstants.SanctionField.points] as? NSNumber)?.intValue,
                  points < 0 else { return nil }
            let resolution = (item[FirestoreConstants.SanctionField.resolution] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return PointSanction(teamCode: teamCode, points: points, resolution: resolution)
        }
    }

    private func buildTeams(from documents: [QueryDocumentSnapshot]) -> [Team] {
        let teamDTOs = documents.compactMap { doc -> TeamDTO? in
            guard let dto = try? doc.data(as: TeamDTO.self) else { return nil }
            let nombreCompleto = dto.name ?? EquipoPeruano.obtenerNombreCompleto(paraId: doc.documentID)
            return TeamDTO(
                id: doc.documentID,
                name: nombreCompleto,
                city: dto.city,
                logo: doc.documentID,
                matchesPlayed: dto.matchesPlayed,
                matchesWon: dto.matchesWon,
                matchesDrawn: dto.matchesDrawn,
                matchesLost: dto.matchesLost,
                goalsScored: dto.goalsScored,
                goalsAgainst: dto.goalsAgainst,
                goalDifference: dto.goalDifference,
                points: dto.points
            )
        }
        let documentIDs = documents.map { $0.documentID }
        var teams = TeamMapper.toDomainArray(from: teamDTOs, documentIDs: documentIDs)
        if teams.allSatisfy({ $0.puntos == 0 }) {
            teams.sort { $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending }
        } else {
            teams.sort { Team.isOrderedAboveInStandings($0, $1) }
        }
        return teams
    }
}
