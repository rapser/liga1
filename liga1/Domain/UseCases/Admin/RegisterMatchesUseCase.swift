//
//  RegisterMatchesUseCase.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import Foundation
import Combine

protocol RegisterMatchesUseCaseProtocol {
    func registerMatch(partido: Partido) -> AnyPublisher<Void, Error>
    func registerMultipleMatches(partidos: [Partido]) -> AnyPublisher<Void, Error>
    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error>
    func finalizeMatch(teamAId: String, teamBId: String, fecha: String) -> AnyPublisher<Void, Error>
}

final class RegisterMatchesUseCase: RegisterMatchesUseCaseProtocol {

    private let adminMatchRepository: AdminMatchRepositoryProtocol

    init(adminMatchRepository: AdminMatchRepositoryProtocol = AdminMatchRepository()) {
        self.adminMatchRepository = adminMatchRepository
    }

    func registerMatch(partido: Partido) -> AnyPublisher<Void, Error> {
        adminMatchRepository.registerMatch(partido: partido)
    }

    func registerMultipleMatches(partidos: [Partido]) -> AnyPublisher<Void, Error> {
        adminMatchRepository.registerMultipleMatches(partidos: partidos)
    }

    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error> {
        adminMatchRepository.updateLiveMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha,
            teamAScore: teamAScore,
            teamBScore: teamBScore
        )
    }

    func finalizeMatch(teamAId: String, teamBId: String, fecha: String) -> AnyPublisher<Void, Error> {
        adminMatchRepository.finalizarPartido(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha
        )
    }
}
