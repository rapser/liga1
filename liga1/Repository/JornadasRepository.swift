//
//  JornadasRepository.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol JornadasRepositoryProtocol {
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
}

class JornadasRepository: JornadasRepositoryProtocol {

    private let db = Firestore.firestore()

    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error> {
        return Future<[Jornada], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "JornadasRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            print("🔍 JornadasRepository: Consultando jornadas con mostrar=true...")

            self.db.collection("jornadas")
                .whereField("mostrar", isEqualTo: true)
                .order(by: "fechaInicio", descending: true)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        print("❌ JornadasRepository: Error en consulta: \(error.localizedDescription)")
                        promise(.failure(error))
                        return
                    }

                    print("📄 JornadasRepository: Documentos obtenidos: \(snapshot?.documents.count ?? 0)")

                    guard let documents = snapshot?.documents else {
                        print("⚠️ JornadasRepository: Sin documentos")
                        promise(.success([]))
                        return
                    }

                    // Debug: mostrar todos los documentos raw
                    documents.forEach { doc in
                        print("  📄 Doc ID: \(doc.documentID), data: \(doc.data())")
                    }

                    let jornadas = documents.compactMap { doc -> Jornada? in
                        do {
                            let jornada = try doc.data(as: Jornada.self)
                            print("  ✅ Jornada parseada: \(jornada.id ?? "sin id")")
                            return jornada
                        } catch {
                            print("  ❌ Error parseando jornada \(doc.documentID): \(error)")
                            return nil
                        }
                    }

                    print("✅ JornadasRepository: Total jornadas parseadas: \(jornadas.count)")
                    promise(.success(jornadas))
                }
        }
        .eraseToAnyPublisher()
    }
}
