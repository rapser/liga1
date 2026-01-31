//
//  JornadasRepository.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

/// Implementación del protocolo JornadasRepositoryProtocol
class JornadasRepository: JornadasRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    private let jornadasSubject = CurrentValueSubject<[Jornada], Never>([])

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore {
        database.db
    }

    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error> {
        return Future<[Jornada], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "JornadasRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            self.db.collection(FirestoreConstants.Collection.jornadas)
                .whereField(FirestoreConstants.JornadaField.mostrar, isEqualTo: true)
                .order(by: FirestoreConstants.JornadaField.fechaInicio, descending: true)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.logger.warning("JornadasRepository: No documents found")
                    promise(.success([]))
                    return
                }

                // Decodificar DTOs desde Firestore y convertir usando el mapper
                    // Pasamos el documentID para extraer torneo y numero si no están en el documento
                    var jornadas: [Jornada] = []
                    for doc in documents {
                        do {
                            var dto = try doc.data(as: JornadaDTO.self)
                            
                            // Si el DTO no tiene id, usar el documentID
                            if dto.id == nil || dto.id?.isEmpty == true {
                                dto = JornadaDTO(
                                    id: doc.documentID,
                                    mostrar: dto.mostrar,
                                    numero: dto.numero,
                                    torneo: dto.torneo,
                                    fechaInicio: dto.fechaInicio
                                )
                            }
                            
                            
                            // Convertir DTO a entidad de dominio, pasando el documentID por si falta
                            if let jornada = JornadaMapper.toDomain(from: dto, documentID: doc.documentID, logger: self.logger) {
                                jornadas.append(jornada)
                            } else {
                                self.logger.warning("JornadasRepository: Failed to map jornada from document \(doc.documentID)")
                            }
                        } catch {
                            self.logger.error("JornadasRepository: Failed to decode JornadaDTO for document \(doc.documentID)", error: error)
                            // Intentar crear jornada manualmente desde el documentID si la decodificación falla
                            let data = doc.data()
                            if let mostrar = data[FirestoreConstants.JornadaField.mostrar] as? Bool,
                               mostrar {
                                // Intentar extraer torneo y numero del documentID
                                if let jornada = JornadaMapper.toDomain(from: JornadaDTO(
                                    id: doc.documentID,
                                    mostrar: mostrar,
                                    numero: nil,
                                    torneo: nil,
                                    fechaInicio: data[FirestoreConstants.JornadaField.fechaInicio] as? Timestamp
                                ), documentID: doc.documentID, logger: self.logger) {
                                    jornadas.append(jornada)
                                }
                            }
                        }
                    }

                    self.jornadasSubject.send(jornadas)
                    promise(.success(jornadas))
                }
        }
        .eraseToAnyPublisher()
    }

    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never> {
        return jornadasSubject.eraseToAnyPublisher()
    }
}
