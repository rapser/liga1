//
//  PollRepository.swift
//  liga1
//

import Foundation
import FirebaseFirestore
import Combine

final class PollRepository: PollRepositoryProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger
    }

    private var db: Firestore { database.db }

    private var pollsCollection: CollectionReference {
        db.collection(FirestoreConstants.Collection.polls)
    }

    // MARK: - Encuesta activa del partido

    func observeActivePoll(matchId: String) -> AnyPublisher<RefereePoll?, Error> {
        let match = matchId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !match.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        // Query simple por matchId (sin orderBy/estado ⇒ sin índice compuesto).
        // El filtrado de "abierta y más reciente" se hace en cliente: son pocos docs por partido.
        return pollsCollection
            .whereField("matchId", isEqualTo: match)
            .snapshotPublisher()
            .map { [logger] snapshot -> RefereePoll? in
                let polls: [RefereePoll] = snapshot.documents.compactMap { doc in
                    do {
                        let dto = try doc.data(as: PollDTO.self)
                        return PollMapper.toDomain(id: doc.documentID, dto: dto)
                    } catch {
                        logger.error("PollRepository: decode falló para \(doc.documentID)", error: error)
                        return nil
                    }
                }
                let now = Date()
                return polls
                    .filter { $0.isOpen(now: now) }
                    .sorted { ($0.creadoEn ?? .distantPast) > ($1.creadoEn ?? .distantPast) }
                    .first
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Conteo agregado (shards)

    func observeTally(pollId: String) -> AnyPublisher<[String: Int], Error> {
        let id = pollId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            return Just([:]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return pollsCollection.document(id)
            .collection(FirestoreConstants.Collection.pollShards)
            .snapshotPublisher()
            .map { [logger] snapshot -> [String: Int] in
                let shards: [PollShardDTO] = snapshot.documents.compactMap { doc in
                    do {
                        return try doc.data(as: PollShardDTO.self)
                    } catch {
                        logger.error("PollRepository: decode de shard \(doc.documentID) falló", error: error)
                        return nil
                    }
                }
                return PollMapper.tally(fromShards: shards)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Voto propio

    func fetchMyVote(pollId: String, uid: String) -> AnyPublisher<String?, Error> {
        let id = pollId.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = uid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !user.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Future<String?, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "PollRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }
            self.db
                .collection(FirestoreConstants.Collection.pollVotes)
                .document(id)
                .collection(FirestoreConstants.Collection.pollVotesEntries)
                .document(user)
                .getDocument(source: .default) { snapshot, error in
                    if let error {
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot, snapshot.exists else {
                        promise(.success(nil))
                        return
                    }
                    let dto = try? snapshot.data(as: PollVoteDTO.self)
                    promise(.success(dto?.opcionId))
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Votar

    func vote(pollId: String, optionId: String, uid: String, numShards: Int) -> AnyPublisher<Void, Error> {
        let id = pollId.trimmingCharacters(in: .whitespacesAndNewlines)
        let option = optionId.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = uid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !option.isEmpty, !user.isEmpty else {
            return Fail(error: NSError(domain: "PollRepository", code: -2,
                                       userInfo: [NSLocalizedDescriptionKey: "Datos de voto incompletos"]))
                .eraseToAnyPublisher()
        }

        return Future<Void, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "PollRepository", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"])))
                return
            }

            let shardIndex = Int.random(in: 0..<max(1, numShards))
            let voteRef = self.db
                .collection(FirestoreConstants.Collection.pollVotes)
                .document(id)
                .collection(FirestoreConstants.Collection.pollVotesEntries)
                .document(user)
            let shardRef = self.pollsCollection.document(id)
                .collection(FirestoreConstants.Collection.pollShards)
                .document(String(shardIndex))

            let batch = self.db.batch()
            // create-only por reglas: si ya votó, el batch entero falla y el shard no se incrementa.
            batch.setData([
                "opcionId": option,
                "ts": FieldValue.serverTimestamp()
            ], forDocument: voteRef)
            batch.updateData([
                "counts.\(option)": FieldValue.increment(Int64(1))
            ], forDocument: shardRef)

            batch.commit { error in
                if let error {
                    self.logger.error("PollRepository: voto falló para \(id)/\(user)", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
