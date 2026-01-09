//
//  MatchesRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Helper para parsear IDs compuestos de partidos
private struct MatchIdComponents {
    let jornadaId: String
    let matchId: String

    /// Parsea un fullMatchId con formato "torneo_numero_equipoA_equipoB" (ej: "apertura_01_atl_uni")
    /// - Returns: MatchIdComponents o nil si el formato es inválido
    static func parse(_ fullMatchId: String) -> MatchIdComponents? {
        let components = fullMatchId.split(separator: "_", maxSplits: 2)
        guard components.count == 3 else {
            return nil
        }

        let torneo = String(components[0])      // "apertura" o "clausura"
        let numero = String(components[1])       // "01"
        let matchId = String(components[2])      // "atl_uni"
        let jornadaId = "\(torneo)_\(numero)"   // "apertura_01"

        return MatchIdComponents(jornadaId: jornadaId, matchId: matchId)
    }
}

/// Implementación del protocolo MatchesRepositoryProtocol
class MatchesRepository: MatchesRepositoryProtocol {

    private let database: DatabaseProtocol

    init(database: DatabaseProtocol) {
        self.database = database
    }

    private var db: Firestore {
        database.db
    }

    func fetchMatches(for jornadaId: String) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "MatchesRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .order(by: FirestoreConstants.MatchField.fecha)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    // Convertir MatchDTO a Match usando el mapper
                    let matchDTOs = documents.compactMap { doc -> MatchDTO? in
                        try? doc.data(as: MatchDTO.self)
                    }
                    
                    let matches = MatchMapper.toDomain(from: matchDTOs)

                    promise(.success(matches))
                }
        }
        .eraseToAnyPublisher()
    }

    func fetchMatchesByIds(matchIds: [String]) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "MatchesRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            guard !matchIds.isEmpty else {
                promise(.success([]))
                return
            }

            // Los matchIds tienen formato: "apertura_01_atl_uni" donde:
            // - apertura_01 es el jornadaId
            // - atl_uni es el matchId dentro de esa jornada
            // Estructura: jornadas/{jornadaId}/matches/{matchId}

            let dispatchGroup = DispatchGroup()
            var allMatches: [Match] = []
            var fetchError: Error?

            for fullMatchId in matchIds {
                guard let idComponents = MatchIdComponents.parse(fullMatchId) else {
                    continue
                }

                dispatchGroup.enter()

                self.db.collection(FirestoreConstants.Collection.jornadas)
                    .document(idComponents.jornadaId)
                    .collection(FirestoreConstants.Collection.matches)
                    .document(idComponents.matchId)
                    .getDocument { snapshot, error in
                        defer { dispatchGroup.leave() }

                        if let error = error {
                            Logger.shared.error("MatchesRepository: Error fetching match \(fullMatchId)", error: error)
                            fetchError = error
                            return
                        }

                        guard let snapshot = snapshot, snapshot.exists else {
                            return
                        }

                        // Convertir MatchDTO a Match usando el mapper
                        if let matchDTO = try? snapshot.data(as: MatchDTO.self),
                           let match = MatchMapper.toDomain(from: matchDTO) {
                            allMatches.append(match)
                        }
                    }
            }

            dispatchGroup.notify(queue: .global()) {
                if let error = fetchError {
                    promise(.failure(error))
                } else {
                    promise(.success(allMatches))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}