//
//  RegisterMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

protocol RegisterMatchesUseCaseProtocol {
    func registerMatch(match: Match, jornadaId: String) -> AnyPublisher<Void, Error>
    func registerMultipleMatches(matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error>
    func updateLiveMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error>
    func finalizeMatch(matchId: String, jornadaId: String) -> AnyPublisher<Void, Error>
}

final class RegisterMatchesUseCase: RegisterMatchesUseCaseProtocol {

    private let adminMatchRepository: AdminMatchRepositoryProtocol

    init(adminMatchRepository: AdminMatchRepositoryProtocol) {
        self.adminMatchRepository = adminMatchRepository
    }

    func registerMatch(match: Match, jornadaId: String) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        if let validationError = validateMatch(match, jornadaId: jornadaId) {
            Logger.shared.error("RegisterMatchesUseCase: Validation failed for single match", error: validationError)
            return Fail(error: validationError).eraseToAnyPublisher()
        }

        return adminMatchRepository.registerMatch(match: match, jornadaId: jornadaId)
            .handleEvents(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("RegisterMatchesUseCase: Failed to register match", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func registerMultipleMatches(matches: [Match], jornadaId: String) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !matches.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "La lista de partidos no puede estar vacía"]
            )
            Logger.shared.error("RegisterMatchesUseCase: Empty matches array", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        // Validar cada partido
        for (index, match) in matches.enumerated() {
            if let validationError = validateMatch(match, jornadaId: jornadaId) {
                Logger.shared.error("RegisterMatchesUseCase: Validation failed for match at index \(index)", error: validationError)
                return Fail(error: validationError).eraseToAnyPublisher()
            }
        }

        return adminMatchRepository.registerMultipleMatches(matches: matches, jornadaId: jornadaId)
            .handleEvents(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("RegisterMatchesUseCase: Failed to register \(matches.count) matches", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func updateLiveMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !matchId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "El ID del partido no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: matchId is empty", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !jornadaId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: jornadaId is empty", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard localScore >= 0 && visitorScore >= 0 else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Los puntajes no pueden ser negativos"]
            )
            Logger.shared.error("RegisterMatchesUseCase: Invalid scores - local: \(localScore), visitor: \(visitorScore)", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return adminMatchRepository.updateLiveMatch(
            matchId: matchId,
            jornadaId: jornadaId,
            localScore: localScore,
            visitorScore: visitorScore
        )
        .handleEvents(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("RegisterMatchesUseCase: Failed to update live match", error: error)
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func finalizeMatch(matchId: String, jornadaId: String) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !matchId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -6,
                userInfo: [NSLocalizedDescriptionKey: "El ID del partido no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: matchId is empty for finalization", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !jornadaId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -8,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: jornadaId is empty for finalization", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return adminMatchRepository.finalizeMatch(
            matchId: matchId,
            jornadaId: jornadaId
        )
        .handleEvents(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("RegisterMatchesUseCase: Failed to finalize match", error: error)
                }
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func validateMatch(_ match: Match, jornadaId: String) -> NSError? {
        guard !match.id.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -9,
                userInfo: [NSLocalizedDescriptionKey: "El ID del partido no puede estar vacío"]
            )
        }

        guard !jornadaId.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -12,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )
        }

        guard let equipoLocalId = match.equipoLocalId, !equipoLocalId.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo local no puede estar vacío"]
            )
        }

        guard let equipoVisitanteId = match.equipoVisitanteId, !equipoVisitanteId.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -11,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo visitante no puede estar vacío"]
            )
        }

        guard equipoLocalId != equipoVisitanteId else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -13,
                userInfo: [NSLocalizedDescriptionKey: "Un equipo no puede jugar contra sí mismo"]
            )
        }

        return nil
    }
}
