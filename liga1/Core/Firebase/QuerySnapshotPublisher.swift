//
//  QuerySnapshotPublisher.swift
//  liga1
//
//  Envuelve `addSnapshotListener` de Firestore en un Publisher de Combine.
//  Es el primer punto del proyecto con escucha en tiempo real (resto usa `getDocuments`
//  puntuales). Se usa para features "en vivo" (encuesta arbitral, y más adelante MVP).
//

import Foundation
import Combine
import FirebaseFirestore

extension Query {
    /// Emite un `QuerySnapshot` por cada cambio del servidor. La suscripción del
    /// listener se remueve al cancelar el `Cancellable`.
    func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        let registration = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
            if let error {
                subject.send(completion: .failure(error))
            } else if let snapshot {
                subject.send(snapshot)
            }
        }
        return subject
            .handleEvents(receiveCancel: { registration.remove() })
            .eraseToAnyPublisher()
    }
}

extension DocumentReference {
    /// Emite un `DocumentSnapshot` por cada cambio del documento.
    func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<DocumentSnapshot, Error> {
        let subject = PassthroughSubject<DocumentSnapshot, Error>()
        let registration = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
            if let error {
                subject.send(completion: .failure(error))
            } else if let snapshot {
                subject.send(snapshot)
            }
        }
        return subject
            .handleEvents(receiveCancel: { registration.remove() })
            .eraseToAnyPublisher()
    }
}
