//
//  TeamsRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
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

            self.db.collection(torneo.rawValue)
                .order(by: FirestoreConstants.TeamField.points, descending: true)
                .order(by: FirestoreConstants.TeamField.goalDifference, descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    // Decodificar DTOs desde Firestore
                    let teamDTOs = documents.compactMap { doc -> TeamDTO? in
                        guard let dto = try? doc.data(as: TeamDTO.self) else {
                            return nil
                        }
                        // Asignar el ID del documento y el nombre completo si no viene
                        let nombreCompleto = dto.name ?? EquipoPeruano.obtenerNombreCompleto(paraId: doc.documentID)
                        
                        return TeamDTO(
                            id: doc.documentID,
                            name: nombreCompleto,
                            city: dto.city,
                            stadium: dto.stadium,
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

                    // Convertir DTOs a entidades de dominio usando el mapper
                    let teams = TeamMapper.toDomainArray(from: teamDTOs)

                    promise(.success(teams))
                }
        }
        .eraseToAnyPublisher()
    }
}
