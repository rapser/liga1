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

            // El orden de Firestore es solo orientativo; el orden final aplica criterios Liga 1 en memoria.
            self.db.collection(torneo.rawValue)
                .order(by: FirestoreConstants.TeamField.points, descending: true)
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
                        // IMPORTANTE: Siempre usar el documentID como logo (código corto del equipo)
                        // El documentID es el código del equipo (ej: "ali", "uni", "cri")
                        // Esto es necesario para los topics de notificaciones push
                        let logo = doc.documentID
                        
                        return TeamDTO(
                            id: doc.documentID,
                            name: nombreCompleto,
                            city: dto.city,
                            stadium: dto.stadium,
                            logo: logo,
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
                    // Pasar los documentIDs para usar como fallback del logo
                    let documentIDs = documents.map { $0.documentID }
                    var teams = TeamMapper.toDomainArray(from: teamDTOs, documentIDs: documentIDs)

                    // Si todos los equipos tienen 0 puntos, ordenar alfabéticamente por nombre
                    // Esto es el caso inicial cuando el torneo aún no ha empezado
                    let allHaveZeroPoints = teams.allSatisfy { $0.puntos == 0 }
                    
                    if allHaveZeroPoints {
                        // Ordenar alfabéticamente por nombre
                        teams.sort { $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending }
                    } else {
                        teams.sort { Team.isOrderedAboveInStandings($0, $1) }
                    }

                    promise(.success(teams))
                }
        }
        .eraseToAnyPublisher()
    }
}
