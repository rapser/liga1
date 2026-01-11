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
    private var jornadasListener: ListenerRegistration?
    
    // Subject para emitir cambios en tiempo real
    private let jornadasSubject = CurrentValueSubject<[Jornada], Never>([])

    init(database: DatabaseProtocol) {
        self.database = database
        startObservingJornadas()
    }
    
    deinit {
        jornadasListener?.remove()
    }

    private var db: Firestore {
        database.db
    }
    
    // MARK: - Private Helpers
    
    private func startObservingJornadas() {
        jornadasListener = db.collection(FirestoreConstants.Collection.jornadas)
            .whereField(FirestoreConstants.JornadaField.mostrar, isEqualTo: true)
            .order(by: FirestoreConstants.JornadaField.fechaInicio, descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    Logger.shared.error("JornadasRepository: Error listening to jornadas", error: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    Logger.shared.warning("JornadasRepository: No documents found in listener")
                    self?.jornadasSubject.send([])
                    return
                }
                
                Logger.shared.debug("JornadasRepository: Listener update - Found \(documents.count) documents")
                
                // Procesar documentos (misma lógica que fetchActiveJornadas)
                var jornadas: [Jornada] = []
                for doc in documents {
                    do {
                        var dto = try doc.data(as: JornadaDTO.self)
                        
                        if dto.id == nil || dto.id?.isEmpty == true {
                            dto = JornadaDTO(
                                id: doc.documentID,
                                mostrar: dto.mostrar,
                                numero: dto.numero,
                                torneo: dto.torneo,
                                fechaInicio: dto.fechaInicio
                            )
                        }
                        
                        if let jornada = JornadaMapper.toDomain(from: dto, documentID: doc.documentID) {
                            jornadas.append(jornada)
                        }
                    } catch {
                        Logger.shared.error("JornadasRepository: Failed to decode JornadaDTO for document \(doc.documentID)", error: error)
                        // Manejo de error similar al método fetchActiveJornadas
                        let data = doc.data()
                        if let mostrar = data[FirestoreConstants.JornadaField.mostrar] as? Bool,
                           mostrar {
                            if let jornada = JornadaMapper.toDomain(from: JornadaDTO(
                                id: doc.documentID,
                                mostrar: mostrar,
                                numero: nil,
                                torneo: nil,
                                fechaInicio: data[FirestoreConstants.JornadaField.fechaInicio] as? Timestamp
                            ), documentID: doc.documentID) {
                                jornadas.append(jornada)
                            }
                        }
                    }
                }
                
                Logger.shared.info("JornadasRepository: Listener update - Mapped \(jornadas.count) jornadas")
                self?.jornadasSubject.send(jornadas)
            }
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
                        Logger.shared.warning("JornadasRepository: No documents found")
                        promise(.success([]))
                        return
                    }

                    Logger.shared.debug("JornadasRepository: Found \(documents.count) documents")

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
                            
                            Logger.shared.debug("JornadasRepository: Processing document \(doc.documentID)")
                            Logger.shared.debug("JornadasRepository: DTO - id: \(dto.id ?? "nil"), mostrar: \(dto.mostrar ?? false), numero: \(dto.numero?.description ?? "nil"), torneo: \(dto.torneo ?? "nil")")
                            
                            // Convertir DTO a entidad de dominio, pasando el documentID por si falta
                            if let jornada = JornadaMapper.toDomain(from: dto, documentID: doc.documentID) {
                                Logger.shared.debug("JornadasRepository: Successfully mapped jornada: \(jornada.id) - \(jornada.torneo) \(jornada.numero)")
                                jornadas.append(jornada)
                            } else {
                                Logger.shared.warning("JornadasRepository: Failed to map jornada from document \(doc.documentID)")
                            }
                        } catch {
                            Logger.shared.error("JornadasRepository: Failed to decode JornadaDTO for document \(doc.documentID)", error: error)
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
                                ), documentID: doc.documentID) {
                                    jornadas.append(jornada)
                                    Logger.shared.debug("JornadasRepository: Created jornada manually from documentID: \(doc.documentID)")
                                }
                            }
                        }
                    }

                    Logger.shared.info("JornadasRepository: Successfully mapped \(jornadas.count) jornadas from \(documents.count) documents")
                    promise(.success(jornadas))
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Reactive Method
    
    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never> {
        return jornadasSubject.eraseToAnyPublisher()
    }
}
