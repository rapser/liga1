//
//  AdminMatchRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para operaciones administrativas de partidos
protocol AdminMatchRepositoryProtocol {
    func registerMatch(match: Match, jornadaId: String) -> AnyPublisher<Void, Error>
    func registerMultipleMatches(matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error>
    func updateMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error>
    func updateLiveMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error>
    func finalizeMatch(matchId: String, jornadaId: String) -> AnyPublisher<Void, Error>
    func finalizeAllMatches() -> AnyPublisher<Void, Error>
    func saveMatches(_ matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error>
}
