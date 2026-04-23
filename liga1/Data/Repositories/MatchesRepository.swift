//
//  MatchesRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo MatchesRepositoryProtocol
class MatchesRepository: MatchesRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol
    
    private var matchSubjects: [String: CurrentValueSubject<[Match], Never>] = [:]
    private let subjectsQueue = DispatchQueue(label: "com.liga1.matchesRepository.subjects")

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
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

            let query = self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .order(by: FirestoreConstants.MatchField.fecha)

            // Estrategia: Intentar caché primero (rápido), luego servidor si falla
            query.getDocuments(source: .cache) { [weak self] cacheSnapshot, cacheError in
                guard let self = self else { return }

                // Si hay datos en caché, úsalos inmediatamente
                if cacheError == nil, let documents = cacheSnapshot?.documents, !documents.isEmpty {
                    self.processMatches(snapshot: cacheSnapshot, jornadaId: jornadaId, promise: promise)

                    // Actualizar desde servidor en background
                    self.fetchMatchesFromServer(query: query, jornadaId: jornadaId)
                } else {
                    // No hay caché, obtener del servidor
                    query.getDocuments(source: .server) { [weak self] snapshot, error in
                        // Si hay un error relacionado con índice faltante, intentar sin ordenar
                        if let error = error as NSError?,
                           error.domain == "FIRFirestoreErrorDomain",
                           error.code == 9 { // Error de índice faltante
                            self?.fetchMatchesWithoutOrder(query: query, jornadaId: jornadaId, promise: promise)
                            return
                        }

                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        self?.processMatches(snapshot: snapshot, jornadaId: jornadaId, promise: promise)
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchMatchesFromServer(query: Query, jornadaId: String) {
        query.getDocuments(source: .server) { [weak self] snapshot, error in
            guard let self = self,
                  error == nil,
                  let documents = snapshot?.documents else {
                return
            }

            let matches = self.processMatchDocuments(documents)
            let sortedMatches = matches.sorted { $0.fecha < $1.fecha }
            self.getOrCreateSubject(for: jornadaId).send(sortedMatches)
        }
    }
    
    private func fetchMatchesWithoutOrder(query: Query, jornadaId: String, promise: @escaping (Result<[Match], Error>) -> Void) {
        query.getDocuments(source: .default) { [weak self] snapshot, error in
            if let error = error {
                promise(.failure(error))
                return
            }

            self?.processMatches(snapshot: snapshot, jornadaId: jornadaId, promise: promise)
        }
    }
    
    private func processMatches(snapshot: QuerySnapshot?, jornadaId: String, promise: @escaping (Result<[Match], Error>) -> Void) {
        guard let documents = snapshot?.documents else {
            getOrCreateSubject(for: jornadaId).send([])
            promise(.success([]))
            return
        }

        let matches = processMatchDocuments(documents)
        let sortedMatches = matches.sorted { $0.fecha < $1.fecha }

        getOrCreateSubject(for: jornadaId).send(sortedMatches)
        promise(.success(sortedMatches))
    }

    private func processMatchDocuments(_ documents: [QueryDocumentSnapshot]) -> [Match] {
        var matchDTOs: [MatchDTO] = []
        for doc in documents {
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
                    return (local, visitante)
                }

                return (nil, nil)
            }()

            // Mapear campos alternativos de goles desde Firestore
            let golesTeamA = data["golesTeamA"] as? Int ?? data["golesEquipoLocal"] as? Int
            let golesTeamB = data["golesTeamB"] as? Int ?? data["golesEquipoVisitante"] as? Int

            // Crear DTO manualmente desde los datos
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

            matchDTOs.append(dto)
        }

        return MatchMapper.toDomain(from: matchDTOs, logger: self.logger)
    }

    func observeMatches(for jornadaId: String) -> AnyPublisher<[Match], Never> {
        return subjectsQueue.sync {
            if let existingSubject = matchSubjects[jornadaId] {
                return existingSubject.eraseToAnyPublisher()
            }
            let subject = CurrentValueSubject<[Match], Never>([])
            matchSubjects[jornadaId] = subject
            return subject.eraseToAnyPublisher()
        }
    }

    private func getOrCreateSubject(for jornadaId: String) -> CurrentValueSubject<[Match], Never> {
        subjectsQueue.sync {
            if let existing = matchSubjects[jornadaId] {
                return existing
            }
            let subject = CurrentValueSubject<[Match], Never>([])
            matchSubjects[jornadaId] = subject
            return subject
        }
    }
}