//
 //  AdminMatchRepository.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo AdminMatchRepositoryProtocol
class AdminMatchRepository: AdminMatchRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore {
        database.db
    }


    func updateMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .document(jornadaId)
                .collection(FirestoreConstants.Collection.matches)
                .document(matchId)
                .updateData([
                    "golesEquipoLocal": localScore,
                    "golesEquipoVisitante": visitorScore
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


    func finalizeAllMatches() -> AnyPublisher<Void, Error> {
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

    func saveMatches(_ matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let batch = self.db.batch()
            let encoder = Firestore.Encoder()

            for match in matches {
                guard !match.id.isEmpty else { continue }
                
                // Convertir Match (Domain) a MatchDTO (Data) usando el mapper
                let matchDTO = MatchMapper.toDTO(from: match)
                
                // Convertir MatchDTO a diccionario para Firestore
                do {
                    let data = try encoder.encode(matchDTO)
                    let docRef = self.db.collection(FirestoreConstants.Collection.jornadas)
                        .document(jornadaId)
                        .collection(FirestoreConstants.Collection.matches)
                        .document(match.id)
                    batch.setData(data, forDocument: docRef)
                } catch {
                    self.logger.error("AdminMatchRepository: Failed to encode match \(match.id)", error: error)
                    // Continuar con el siguiente match
                }
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

    // MARK: - Nuevos Métodos de Registro de Jornadas

    func registerJornadaWithMatches(jornadaId: String, mostrar: Bool, fechaInicio: Date, matches: [Match]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let batch = self.db.batch()
            
            // Validar formato del jornadaId (ej: "apertura_01")
            let components = jornadaId.split(separator: "_")
            guard components.count >= 2,
                  Int(String(components[1])) != nil else {
                promise(.failure(NSError(domain: "AdminMatchRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid jornadaId format: \(jornadaId). Expected format: 'torneo_numero'"])))
                return
            }
            
            // 1. Crear documento de jornada con SOLO los campos que existen en Firestore
            // NO incluimos: id, torneo, numero (estos están solo en el documentID)
            let jornadaRef = self.db.collection(FirestoreConstants.Collection.jornadas).document(jornadaId)
            
            let jornadaData: [String: Any] = [
                "mostrar": mostrar,
                "fechaInicio": Timestamp(date: fechaInicio)
            ]
            
            batch.setData(jornadaData, forDocument: jornadaRef)
            
            // 2. Crear subcolección de matches
            // Cada match se guarda como documento en matches/ con documentID = match.id (ej: "cou_moq")
            // IMPORTANTE: Solo escribimos los 5 campos especificados, NO id, equipoLocalId, equipoVisitanteId
            for match in matches {
                let matchRef = jornadaRef.collection(FirestoreConstants.Collection.matches).document(match.id)
                
                // Crear diccionario con solo los 5 campos que existen en Firestore
                let matchData: [String: Any] = [
                    "estado": match.estado.rawValue,  // "pendiente"
                    "fecha": Timestamp(date: match.fecha),
                    "golesEquipoLocal": match.golesEquipoLocal,
                    "golesEquipoVisitante": match.golesEquipoVisitante,
                    "suspendido": match.suspendido
                    // NO incluimos: id, equipoLocalId, equipoVisitanteId (están en el documentID)
                ]
                
                batch.setData(matchData, forDocument: matchRef)
            }
            
            batch.commit { error in
                if let error = error {
                    self.logger.error("AdminMatchRepository: Failed to register jornada \(jornadaId)", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func registerAllAperturaJornadas() -> AnyPublisher<Void, Error> {
        let fechaBase = AperturaFixtureData.fechaBase
        var _: [AnyPublisher<Void, Error>] = []
        
        // Crear publishers para cada una de las 17 jornadas
        // Ejecutamos secuencialmente para evitar sobrecargar Firestore
        return Publishers.Sequence(sequence: (1...17).map { numeroJornada -> AnyPublisher<Void, Error> in
            let jornadaId = String(format: "apertura_%02d", numeroJornada)
            let matches = AperturaFixtureData.crearMatchesParaJornada(numeroJornada, fecha: fechaBase)
            
            return registerJornadaWithMatches(
                jornadaId: jornadaId,
                mostrar: false, // Por defecto false
                fechaInicio: fechaBase,
                matches: matches
            )
        })
        .flatMap(maxPublishers: .max(1)) { $0 }  // Ejecutar una a la vez
        .collect()
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
