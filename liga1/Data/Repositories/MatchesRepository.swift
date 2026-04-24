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

            let golesTeamA = data["golesTeamA"] as? Int ?? data["golesEquipoLocal"] as? Int
            let golesTeamB = data["golesTeamB"] as? Int ?? data["golesEquipoVisitante"] as? Int

            let arbitro = data["arbitro"] as? String ?? data["nombreArbitro"] as? String
            let estadio = data["estadio"] as? String ?? data["nombreEstadio"] as? String
            let capacidad = Self.stringFromFirestoreValue(data["capacidad"])
            let canalesTV = Self.parseCanalesTV(from: data)
            let liveStats = Self.parseLiveStatsDTO(from: data)

            let dto = MatchDTO(
                id: documentID,
                equipoLocalId: equipoLocalId,
                equipoVisitanteId: equipoVisitanteId,
                fecha: data["fecha"] as? Timestamp,
                golesTeamA: golesTeamA,
                golesTeamB: golesTeamB,
                estado: data["estado"] as? String,
                suspendido: data["suspendido"] as? Bool,
                arbitro: arbitro,
                estadio: estadio,
                capacidad: capacidad,
                canalesTV: canalesTV,
                liveStats: liveStats
            )

            matchDTOs.append(dto)
        }

        return MatchMapper.toDomain(from: matchDTOs, logger: self.logger)
    }

    private static func stringFromFirestoreValue(_ value: Any?) -> String? {
        if let s = value as? String, !s.isEmpty { return s }
        if let n = value as? NSNumber { return n.stringValue }
        if let i = value as? Int { return String(i) }
        return nil
    }

    private static func parseCanalesTV(from data: [String: Any]) -> [String]? {
        if let arr = data["canalesTV"] as? [String], !arr.isEmpty { return arr }
        if let arr = data["canalesTV"] as? [Any] {
            let strings = arr.compactMap { $0 as? String }
            return strings.isEmpty ? nil : strings
        }
        if let s = data["canalTV"] as? String, !s.isEmpty { return [s] }
        return nil
    }

    private static func parseLiveStatsDTO(from data: [String: Any]) -> MatchLiveStatsDTO? {
        let nested = data["stats"] as? [String: Any]
        let src = nested ?? data

        func intVal(_ key: String) -> Int? {
            if let i = src[key] as? Int { return i }
            if let n = src[key] as? NSNumber { return n.intValue }
            return nil
        }

        func pair(prefix: String) -> (Int?, Int?) {
            let l = intVal("\(prefix)Local") ?? intVal("\(prefix)_local")
            let v = intVal("\(prefix)Visitante") ?? intVal("\(prefix)_visitante")
            return (l, v)
        }

        func nestedPair(_ key: String) -> (Int?, Int?) {
            guard let o = src[key] as? [String: Any] else { return (nil, nil) }
            let l = o["local"] as? Int ?? (o["local"] as? NSNumber)?.intValue
            let r = o["visitante"] as? Int ?? (o["visitante"] as? NSNumber)?.intValue
            return (l, r)
        }

        var pl: Int?
        var pv: Int?
        (pl, pv) = pair(prefix: "posesion")
        if pl == nil && pv == nil { (pl, pv) = nestedPair("posesion") }

        var rl: Int?
        var rv: Int?
        (rl, rv) = pair(prefix: "remates")
        if rl == nil && rv == nil { (rl, rv) = nestedPair("remates") }

        var tl: Int?
        var tv: Int?
        (tl, tv) = pair(prefix: "tirosAPuerta")
        if tl == nil && tv == nil { (tl, tv) = pair(prefix: "tirosPuerta") }
        if tl == nil && tv == nil { (tl, tv) = nestedPair("tirosAPuerta") }

        var cl: Int?
        var cv: Int?
        (cl, cv) = pair(prefix: "corners")
        if cl == nil && cv == nil { (cl, cv) = nestedPair("corners") }

        let dto = MatchLiveStatsDTO(
            posesionLocal: pl,
            posesionVisitante: pv,
            rematesLocal: rl,
            rematesVisitante: rv,
            tirosAPuertaLocal: tl,
            tirosAPuertaVisitante: tv,
            cornersLocal: cl,
            cornersVisitante: cv
        )
        let empty = dto.posesionLocal == nil && dto.posesionVisitante == nil
            && dto.rematesLocal == nil && dto.rematesVisitante == nil
            && dto.tirosAPuertaLocal == nil && dto.tirosAPuertaVisitante == nil
            && dto.cornersLocal == nil && dto.cornersVisitante == nil
        return empty ? nil : dto
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