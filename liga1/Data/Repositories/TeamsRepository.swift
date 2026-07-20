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

    init(database: DatabaseProtocol) {
        self.database = database
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

    func invalidateCache(for torneo: TorneoType?) {
        // La caché del SDK de Firestore se gestiona internamente; no hay estado en memoria aquí.
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
