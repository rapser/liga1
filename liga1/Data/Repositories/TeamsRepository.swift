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

    private let db = Firestore.firestore()

    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        return Future<[Team], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "TeamsRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(torneo.rawValue)
                .order(by: "points", descending: true)
                .order(by: "goalDifference", descending: true)
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
                            ciudad: data["city"] as? String ?? "Sin ciudad",
                            estadio: data["stadium"] as? String ?? "Sin estadio",
                            logo: data["logo"] as? String ?? "Sin logo",
                            partidosJugados: data["matchesPlayed"] as? Int ?? 0,
                            partidosGanados: data["matchesWon"] as? Int ?? 0,
                            partidosEmpatados: data["matchesDrawn"] as? Int ?? 0,
                            partidosPerdidos: data["matchesLost"] as? Int ?? 0,
                            golesFavor: data["goalsScored"] as? Int ?? 0,
                            golesContra: data["goalsAgainst"] as? Int ?? 0,
                            diferenciaGoles: data["goalDifference"] as? Int ?? 0,
                            puntos: data["points"] as? Int ?? 0
                        )
                    }

                    promise(.success(teams))
                }
        }
        .eraseToAnyPublisher()
    }
}
