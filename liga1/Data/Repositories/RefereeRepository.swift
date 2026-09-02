//
//  RefereeRepository.swift
//  liga1
//

import Foundation
import FirebaseFirestore
import Combine

final class RefereeRepository: RefereeRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore { database.db }

    func fetchReferee(id refereeId: String) -> AnyPublisher<RefereeProfile?, Error> {
        Future<RefereeProfile?, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "RefereeRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }
            let id = refereeId.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { promise(.success(nil)); return }

            self.db.collection(FirestoreConstants.Collection.referees)
                .document(id)
                .getDocument(source: .default) { snapshot, error in
                    if let error {
                        self.logger.error("RefereeRepository: fetch falló para \(id)", error: error)
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot, snapshot.exists else {
                        promise(.success(nil))
                        return
                    }
                    do {
                        let dto = try snapshot.data(as: RefereeDTO.self)
                        promise(.success(RefereeMapper.toDomain(from: dto, id: snapshot.documentID)))
                    } catch {
                        self.logger.error("RefereeRepository: decode falló para \(id)", error: error)
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
