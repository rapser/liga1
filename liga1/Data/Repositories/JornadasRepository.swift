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

            // Solo `mostrar == true`. No ordenar por `fechaInicio` (el Home usa el calendario / fechas de partido).
            let query = self.db.collection(FirestoreConstants.Collection.jornadas)
                .whereField(FirestoreConstants.JornadaField.mostrar, isEqualTo: true)

            // Estrategia: Intentar caché primero (rápido), luego servidor si falla
            query.getDocuments(source: .cache) { [weak self] cacheSnapshot, cacheError in
                guard let self = self else { return }

                // Si hay datos en caché, úsalos inmediatamente
                if cacheError == nil, let documents = cacheSnapshot?.documents, !documents.isEmpty {
                    let jornadas = self.processJornadaDocuments(documents)
                    self.jornadasSubject.send(jornadas)
                    promise(.success(jornadas))

                    // Actualizar desde servidor en background para tener datos frescos
                    self.fetchFromServer(query: query)
                } else {
                    // No hay caché, obtener del servidor (primera carga)
                    query.getDocuments(source: .server) { snapshot, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            self.logger.warning("JornadasRepository: No documents found")
                            promise(.success([]))
                            return
                        }

                        let jornadas = self.processJornadaDocuments(documents)
                        self.jornadasSubject.send(jornadas)
                        promise(.success(jornadas))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func fetchFromServer(query: Query) {
        query.getDocuments(source: .server) { [weak self] snapshot, error in
            guard let self = self,
                  error == nil,
                  let documents = snapshot?.documents else {
                return
            }

            let jornadas = self.processJornadaDocuments(documents)
            self.jornadasSubject.send(jornadas)
        }
    }

    private func processJornadaDocuments(_ documents: [QueryDocumentSnapshot]) -> [Jornada] {
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
        return jornadas
    }

    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never> {
        return jornadasSubject.eraseToAnyPublisher()
    }
}
