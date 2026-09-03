//
//  PollRepositoryProtocol.swift
//  liga1
//

import Foundation
import Combine

/// Acceso a las encuestas arbitrales en vivo.
protocol PollRepositoryProtocol {

    /// Encuesta abierta más reciente del partido; emite en tiempo real. `nil` si no hay.
    func observeActivePoll(matchId: String) -> AnyPublisher<RefereePoll?, Error>

    /// Conteo agregado (suma de shards) de la encuesta; emite en tiempo real.
    func observeTally(pollId: String) -> AnyPublisher<[String: Int], Error>

    /// Voto previo del usuario en esta encuesta (`optionId`), o `nil` si no votó.
    func fetchMyVote(pollId: String, uid: String) -> AnyPublisher<String?, Error>

    /// Registra el voto: escribe `pollVotes/{pollId}/votes/{uid}` e incrementa un shard
    /// al azar, en un batch atómico. Falla si el usuario ya votó (reglas: create-only).
    func vote(pollId: String, optionId: String, uid: String, numShards: Int) -> AnyPublisher<Void, Error>
}
