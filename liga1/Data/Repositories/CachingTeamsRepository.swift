//
//  CachingTeamsRepository.swift
//  liga1
//
//  Data/Repositories: Decorator Pattern sobre TeamsRepositoryProtocol.
//  Añade caché en memoria por TorneoType; transparente para cualquier caller.
//

import Foundation
import Combine

final class CachingTeamsRepository: TeamsRepositoryProtocol {

    private let inner: TeamsRepositoryProtocol
    private var cache: [TorneoType: [Team]] = [:]
    private let lock = NSLock()

    init(wrapping inner: TeamsRepositoryProtocol) {
        self.inner = inner
    }

    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        lock.lock()
        if let cached = cache[torneo] {
            lock.unlock()
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        lock.unlock()

        return inner.fetchTeams(for: torneo)
            .handleEvents(receiveOutput: { [weak self] teams in
                self?.lock.lock()
                self?.cache[torneo] = teams
                self?.lock.unlock()
            })
            .eraseToAnyPublisher()
    }

    /// El listener ya mantiene la tabla viva; se pasa directo al repositorio.
    func observeTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Never> {
        inner.observeTeams(for: torneo)
            .handleEvents(receiveOutput: { [weak self] teams in
                // Mantiene fresca la caché que usan las lecturas puntuales (simulador).
                self?.lock.lock()
                self?.cache[torneo] = teams
                self?.lock.unlock()
            })
            .eraseToAnyPublisher()
    }

    func refreshStandings(for torneos: [TorneoType], completion: @escaping (Bool) -> Void) {
        // La caché en memoria de lecturas puntuales queda vieja: se descarta.
        torneos.forEach { invalidateCache(for: $0) }
        inner.refreshStandings(for: torneos, completion: completion)
    }

    func observePointSanctions() -> AnyPublisher<[PointSanction], Never> {
        inner.observePointSanctions()
    }

    func invalidateCache(for torneo: TorneoType?) {
        lock.lock()
        defer { lock.unlock() }
        if let torneo = torneo {
            cache.removeValue(forKey: torneo)
        } else {
            cache.removeAll()
        }
    }
}
