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

            Logger.shared.debug("MatchesRepository: Fetching matches for jornada: \(jornadaId)")
            
            let query = self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
            
            // Intentar ordenar por fecha, pero si falla, obtener sin ordenar
            query
                .order(by: FirestoreConstants.MatchField.fecha)
                .getDocuments(source: .default) { [weak self] snapshot, error in
                    // Si hay un error relacionado con índice faltante, intentar sin ordenar
                    if let error = error as NSError?,
                       error.domain == "FIRFirestoreErrorDomain",
                       error.code == 9 { // Error de índice faltante
                        Logger.shared.warning("MatchesRepository: Index missing for fecha field, fetching without order")
                        self?.fetchMatchesWithoutOrder(query: query, jornadaId: jornadaId, promise: promise)
                        return
                    }
                    
                    if let error = error {
                        Logger.shared.error("MatchesRepository: Error fetching matches for jornada \(jornadaId)", error: error)
                        promise(.failure(error))
                        return
                    }
                    
                    self?.processMatches(snapshot: snapshot, jornadaId: jornadaId, promise: promise)
                }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchMatchesWithoutOrder(query: Query, jornadaId: String, promise: @escaping (Result<[Match], Error>) -> Void) {
        query.getDocuments(source: .default) { [weak self] snapshot, error in
            if let error = error {
                Logger.shared.error("MatchesRepository: Error fetching matches without order for jornada \(jornadaId)", error: error)
                promise(.failure(error))
                return
            }
            
            self?.processMatches(snapshot: snapshot, jornadaId: jornadaId, promise: promise)
        }
    }
    
    private func processMatches(snapshot: QuerySnapshot?, jornadaId: String, promise: @escaping (Result<[Match], Error>) -> Void) {
        guard let documents = snapshot?.documents else {
            Logger.shared.warning("MatchesRepository: No documents found for jornada \(jornadaId)")
            promise(.success([]))
            return
        }

        Logger.shared.debug("MatchesRepository: Found \(documents.count) documents for jornada \(jornadaId)")

        // Convertir MatchDTO a Match usando el mapper
        var matchDTOs: [MatchDTO] = []
        for doc in documents {
            Logger.shared.debug("MatchesRepository: Processing document \(doc.documentID)")
            Logger.shared.debug("MatchesRepository: Document data keys: \(doc.data().keys.joined(separator: ", "))")
            
            let documentID = doc.documentID
            let data = doc.data()
            
            // Extraer equipoLocalId y equipoVisitanteId del documentID
            // Format: "equipoLocal_equipoVisitante" (ej: "adt_utc", "atl_uni")
            let (equipoLocalId, equipoVisitanteId): (String?, String?) = {
                // Primero intentar obtener desde el documento
                if let local = data["equipoLocalId"] as? String,
                   let visitante = data["equipoVisitanteId"] as? String {
                    return (local, visitante)
                }
                
                // Si no están en el documento, extraer del documentID
                let components = documentID.split(separator: "_")
                if components.count >= 2 {
                    let local = String(components[0])
                    let visitante = String(components[1])
                    Logger.shared.debug("MatchesRepository: Extracted equipoLocalId=\(local), equipoVisitanteId=\(visitante) from documentID: \(documentID)")
                    return (local, visitante)
                }
                
                Logger.shared.warning("MatchesRepository: Cannot extract equipoLocalId and equipoVisitanteId from documentID: \(documentID)")
                return (nil, nil)
            }()
            
            // Mapear campos alternativos de goles desde Firestore
            // Los documentos tienen "golesEquipoLocal" y "golesEquipoVisitante"
            // pero el DTO espera "golesTeamA" y "golesTeamB"
            let golesTeamA = data["golesTeamA"] as? Int ?? data["golesEquipoLocal"] as? Int
            let golesTeamB = data["golesTeamB"] as? Int ?? data["golesEquipoVisitante"] as? Int
            
            // Crear DTO manualmente desde los datos
            // Esto evita problemas con @DocumentID y maneja correctamente los campos alternativos
            let dto = MatchDTO(
                id: documentID,
                equipoLocalId: equipoLocalId,
                equipoVisitanteId: equipoVisitanteId,
                fecha: data["fecha"] as? Timestamp,
                golesTeamA: golesTeamA,
                golesTeamB: golesTeamB,
                estado: data["estado"] as? String,
                suspendido: data["suspendido"] as? Bool
            )
            
            Logger.shared.debug("MatchesRepository: Successfully created MatchDTO: id=\(dto.id ?? "nil"), equipoLocal=\(dto.equipoLocalId ?? "nil"), equipoVisitante=\(dto.equipoVisitanteId ?? "nil"), fecha=\(dto.fecha?.dateValue().description ?? "nil"), golesA=\(dto.golesTeamA ?? 0), golesB=\(dto.golesTeamB ?? 0)")
            matchDTOs.append(dto)
        }
        
        Logger.shared.debug("MatchesRepository: Successfully decoded \(matchDTOs.count) MatchDTOs for jornada \(jornadaId) out of \(documents.count) documents")
        
        let matches = MatchMapper.toDomain(from: matchDTOs)
        
        // Ordenar manualmente por fecha si no se ordenó en Firestore
        let sortedMatches = matches.sorted { $0.fecha < $1.fecha }
        
        Logger.shared.info("MatchesRepository: Successfully mapped \(sortedMatches.count) matches for jornada \(jornadaId) from \(matchDTOs.count) DTOs")
        promise(.success(sortedMatches))
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

                        // Crear MatchDTO manualmente desde los datos del documento
                        let documentID = snapshot.documentID
                        let data = snapshot.data() ?? [:]
                        
                        // Extraer equipoLocalId y equipoVisitanteId del documentID
                        let (equipoLocalId, equipoVisitanteId): (String?, String?) = {
                            if let local = data["equipoLocalId"] as? String,
                               let visitante = data["equipoVisitanteId"] as? String {
                                return (local, visitante)
                            }
                            
                            let components = documentID.split(separator: "_")
                            if components.count >= 2 {
                                return (String(components[0]), String(components[1]))
                            }
                            return (nil, nil)
                        }()
                        
                        // Mapear campos de goles
                        let golesTeamA = data["golesTeamA"] as? Int ?? data["golesEquipoLocal"] as? Int
                        let golesTeamB = data["golesTeamB"] as? Int ?? data["golesEquipoVisitante"] as? Int
                        
                        let matchDTO = MatchDTO(
                            id: documentID,
                            equipoLocalId: equipoLocalId,
                            equipoVisitanteId: equipoVisitanteId,
                            fecha: data["fecha"] as? Timestamp,
                            golesTeamA: golesTeamA,
                            golesTeamB: golesTeamB,
                            estado: data["estado"] as? String,
                            suspendido: data["suspendido"] as? Bool
                        )
                        
                        // Convertir MatchDTO a Match usando el mapper
                        if let match = MatchMapper.toDomain(from: matchDTO) {
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