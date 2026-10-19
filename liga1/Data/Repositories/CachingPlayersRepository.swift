//
//  CachingPlayersRepository.swift
//  liga1
//
//  Data/Repositories: Decorator Pattern sobre PlayersRepositoryProtocol.
//  Las plantillas casi no cambian: se cachean en memoria por equipo durante la sesión.
//

import Foundation
import Combine

final class CachingPlayersRepository: PlayersRepositoryProtocol {

    private let inner: PlayersRepositoryProtocol
    private var cache: [String: [Player]] = [:]
    private let lock = NSLock()

    init(wrapping inner: PlayersRepositoryProtocol) {
        self.inner = inner
    }

    func fetchSquad(teamId: String) -> AnyPublisher<[Player], Error> {
        lock.lock()
        if let cached = cache[teamId] {
            lock.unlock()
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        lock.unlock()

        return inner.fetchSquad(teamId: teamId)
            .handleEvents(receiveOutput: { [weak self] players in
                self?.lock.lock()
                self?.cache[teamId] = players
                self?.lock.unlock()
            })
            .eraseToAnyPublisher()
    }
}
