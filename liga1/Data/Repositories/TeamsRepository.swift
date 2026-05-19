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

            // Caché primero: muestra equipos al instante en visitas sucesivas;
            // el refresh en background actualiza la caché para la próxima consulta.
            query.getDocuments(source: .cache) { [weak self] cacheSnapshot, cacheError in
                guard let self = self else { return }

                if cacheError == nil, let docs = cacheSnapshot?.documents, !docs.isEmpty {
                    promise(.success(self.buildTeams(from: docs)))
                    // Background: actualiza caché del SDK para la próxima visita.
                    query.getDocuments(source: .server) { _, _ in }
                } else {
                    // Sin caché (primera carga), ir al servidor.
                    query.getDocuments(source: .server) { [weak self] snapshot, error in
                        guard let self = self else { return }
                        if let error = error { promise(.failure(error)); return }
                        guard let docs = snapshot?.documents else { promise(.success([])); return }
                        promise(.success(self.buildTeams(from: docs)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
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
