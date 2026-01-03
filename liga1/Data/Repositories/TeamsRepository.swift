//
//  TeamsRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol TeamsRepositoryProtocol {
    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
}

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

                    let teams = documents.map { doc -> Team in
                        let data = doc.data()
                        return Team(
                            nombre: EquipoPeruano.obtenerNombreCompleto(paraId: doc.documentID),
                            ciudad: data[FirestoreConstants.TeamField.city] as? String ?? "Sin ciudad",
                            estadio: data[FirestoreConstants.TeamField.stadium] as? String ?? "Sin estadio",
                            logo: data["logo"] as? String ?? "Sin logo",
                            partidosJugados: data[FirestoreConstants.TeamField.matchesPlayed] as? Int ?? 0,
                            partidosGanados: data[FirestoreConstants.TeamField.matchesWon] as? Int ?? 0,
                            partidosEmpatados: data[FirestoreConstants.TeamField.matchesDrawn] as? Int ?? 0,
                            partidosPerdidos: data[FirestoreConstants.TeamField.matchesLost] as? Int ?? 0,
                            golesFavor: data[FirestoreConstants.TeamField.goalsScored] as? Int ?? 0,
                            golesContra: data[FirestoreConstants.TeamField.goalsAgainst] as? Int ?? 0,
                            diferenciaGoles: data[FirestoreConstants.TeamField.goalDifference] as? Int ?? 0,
                            puntos: data[FirestoreConstants.TeamField.points] as? Int ?? 0
                        )
                    }

                    promise(.success(teams))
                }
        }
        .eraseToAnyPublisher()
    }
}
