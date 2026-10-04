//
//  FetchSquadUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol FetchSquadUseCaseProtocol {
    func execute(teamId: String) -> AnyPublisher<[Player], Error>
}

/// Plantilla de un equipo ordenada como se muestra: por línea (portero → delantero), dorsal y nombre.
final class FetchSquadUseCase: FetchSquadUseCaseProtocol {

    private let repository: PlayersRepositoryProtocol

    init(repository: PlayersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(teamId: String) -> AnyPublisher<[Player], Error> {
        repository.fetchSquad(teamId: teamId)
            .map(Self.sortedForSquad)
            .eraseToAnyPublisher()
    }

    /// Jugadores sin dorsal van al final de su línea.
    static func sortedForSquad(_ players: [Player]) -> [Player] {
        let order = PlayerPosition.allCases
        return players.sorted { lhs, rhs in
            if lhs.position != rhs.position {
                return (order.firstIndex(of: lhs.position) ?? 0) < (order.firstIndex(of: rhs.position) ?? 0)
            }
            switch (lhs.number, rhs.number) {
            case let (l?, r?) where l != r: return l < r
            case (_?, nil): return true
            case (nil, _?): return false
            default: return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }
}
