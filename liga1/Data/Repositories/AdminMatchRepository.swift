//
//  AdminMatchRepository.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol AdminMatchRepositoryProtocol {
    func registerMatch(partido: Partido) -> AnyPublisher<Void, Error>
    func registerMultipleMatches(partidos: [Partido]) -> AnyPublisher<Void, Error>
    func updateMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error>
    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error>
    func finalizarPartido(teamAId: String, teamBId: String, fecha: String) -> AnyPublisher<Void, Error>
    func finalizarTodosLosPartidos() -> AnyPublisher<Void, Error>
    func saveMatches(_ matches: [Match]) -> AnyPublisher<Void, Error>
}

class AdminMatchRepository: AdminMatchRepositoryProtocol {

    private let db = FirestoreManager.shared.db

    func registerMatch(partido: Partido) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            // Estructura: jornadas/{jornadaId}/matches/{matchId}
            // matchId: adt_utc (código de 3 letras de cada equipo)
            let matchId = "\(partido.teamAId)_\(partido.teamBId)"

            let matchData: [String: Any] = [
                "equipoLocalId": partido.teamAId,
                "equipoVisitanteId": partido.teamBId,
                "golesTeamA": partido.golesTeamA,
                "golesTeamB": partido.golesTeamB,
                "estado": partido.estado.rawValue,
                "suspendido": false,
                "fecha": Timestamp(date: Date()) // Puedes ajustar esto según necesites
            ]

            self.db.collection("jornadas")
                .document(partido.jornadaId)
                .collection("matches")
                .document(matchId)
                .setData(matchData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func registerMultipleMatches(partidos: [Partido]) -> AnyPublisher<Void, Error> {
        let publishers = partidos.map { registerMatch(partido: $0) }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func updateMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            // El parámetro 'fecha' ahora representa el jornadaId completo (ej: "clausura_01")
            let matchId = "\(teamAId)_\(teamBId)"

            self.db.collection("jornadas")
                .document(fecha)
                .collection("matches")
                .document(matchId)
                .updateData([
                    "golesTeamA": teamAScore,
                    "golesTeamB": teamBScore
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            // El parámetro 'fecha' ahora representa el jornadaId completo (ej: "clausura_01")
            let matchId = "\(teamAId)_\(teamBId)"

            self.db.collection("jornadas")
                .document(fecha)
                .collection("matches")
                .document(matchId)
                .updateData([
                    "golesTeamA": teamAScore,
                    "golesTeamB": teamBScore,
                    "estado": "enJuego"
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func finalizarPartido(teamAId: String, teamBId: String, fecha: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            // El parámetro 'fecha' ahora representa el jornadaId completo (ej: "clausura_01")
            let matchId = "\(teamAId)_\(teamBId)"

            self.db.collection("jornadas")
                .document(fecha)
                .collection("matches")
                .document(matchId)
                .updateData([
                    "estado": "finalizado"
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func finalizarTodosLosPartidos() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.matches).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    promise(.success(()))
                    return
                }

                let batch = self.db.batch()

                for document in documents {
                    let matchRef = self.db.collection(FirestoreConstants.Collection.matches).document(document.documentID)
                    batch.updateData([FirestoreConstants.MatchField.estado: FirestoreConstants.MatchState.finished], forDocument: matchRef)
                }

                batch.commit { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveMatches(_ matches: [Match]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let batch = self.db.batch()

            for match in matches {
                let matchId = match.id ?? "\(match.equipoLocalId ?? "")_\(match.equipoVisitanteId ?? "")"
                let docRef = self.db.collection(FirestoreConstants.Collection.matches).document(matchId)
                batch.setData(match.toDictionary(), forDocument: docRef)
            }

            batch.commit { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
