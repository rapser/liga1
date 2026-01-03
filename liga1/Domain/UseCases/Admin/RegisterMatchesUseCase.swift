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

    init(adminMatchRepository: AdminMatchRepositoryProtocol) {
        self.adminMatchRepository = adminMatchRepository
    }

    func registerMatch(partido: Partido) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        if let validationError = validatePartido(partido) {
            Logger.shared.error("RegisterMatchesUseCase: Validation failed for single match", error: validationError)
            return Fail(error: validationError).eraseToAnyPublisher()
        }

        Logger.shared.debug("RegisterMatchesUseCase: Registering single match - \(partido.equipoA) vs \(partido.equipoB)")

        return adminMatchRepository.registerMatch(partido: partido)
            .handleEvents(
                receiveOutput: { _ in
                    Logger.shared.info("RegisterMatchesUseCase: Successfully registered match - \(partido.equipoA) vs \(partido.equipoB)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("RegisterMatchesUseCase: Failed to register match - \(partido.equipoA) vs \(partido.equipoB)", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func registerMultipleMatches(partidos: [Partido]) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !partidos.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "La lista de partidos no puede estar vacía"]
            )
            Logger.shared.error("RegisterMatchesUseCase: Empty partidos array", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        // Validar cada partido
        for (index, partido) in partidos.enumerated() {
            if let validationError = validatePartido(partido) {
                Logger.shared.error("RegisterMatchesUseCase: Validation failed for match at index \(index)", error: validationError)
                return Fail(error: validationError).eraseToAnyPublisher()
            }
        }

        Logger.shared.debug("RegisterMatchesUseCase: Registering \(partidos.count) matches")

        return adminMatchRepository.registerMultipleMatches(partidos: partidos)
            .handleEvents(
                receiveOutput: { _ in
                    Logger.shared.info("RegisterMatchesUseCase: Successfully registered \(partidos.count) matches")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("RegisterMatchesUseCase: Failed to register \(partidos.count) matches", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !teamAId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo A no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: teamAId is empty", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !teamBId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo B no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: teamBId is empty", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !fecha.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "La fecha no puede estar vacía"]
            )
            Logger.shared.error("RegisterMatchesUseCase: fecha is empty", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard teamAScore >= 0 && teamBScore >= 0 else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Los puntajes no pueden ser negativos"]
            )
            Logger.shared.error("RegisterMatchesUseCase: Invalid scores - teamA: \(teamAScore), teamB: \(teamBScore)", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        Logger.shared.debug("RegisterMatchesUseCase: Updating live match - Score: \(teamAScore)-\(teamBScore)")

        return adminMatchRepository.updateLiveMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha,
            teamAScore: teamAScore,
            teamBScore: teamBScore
        )
        .handleEvents(
            receiveOutput: { _ in
                Logger.shared.info("RegisterMatchesUseCase: Successfully updated live match - Score: \(teamAScore)-\(teamBScore)")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("RegisterMatchesUseCase: Failed to update live match", error: error)
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func finalizeMatch(teamAId: String, teamBId: String, fecha: String) -> AnyPublisher<Void, Error> {
        // Validaciones de negocio
        guard !teamAId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -6,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo A no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: teamAId is empty for finalization", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !teamBId.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -7,
                userInfo: [NSLocalizedDescriptionKey: "El ID del equipo B no puede estar vacío"]
            )
            Logger.shared.error("RegisterMatchesUseCase: teamBId is empty for finalization", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard !fecha.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -8,
                userInfo: [NSLocalizedDescriptionKey: "La fecha no puede estar vacía"]
            )
            Logger.shared.error("RegisterMatchesUseCase: fecha is empty for finalization", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }

        Logger.shared.debug("RegisterMatchesUseCase: Finalizing match")

        return adminMatchRepository.finalizarPartido(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha
        )
        .handleEvents(
            receiveOutput: { _ in
                Logger.shared.info("RegisterMatchesUseCase: Successfully finalized match")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("RegisterMatchesUseCase: Failed to finalize match", error: error)
                }
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func validatePartido(_ partido: Partido) -> NSError? {
        guard !partido.equipoA.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -9,
                userInfo: [NSLocalizedDescriptionKey: "El nombre del equipo A no puede estar vacío"]
            )
        }

        guard !partido.equipoB.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey: "El nombre del equipo B no puede estar vacío"]
            )
        }

        guard !partido.fecha.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -11,
                userInfo: [NSLocalizedDescriptionKey: "La fecha no puede estar vacía"]
            )
        }

        guard !partido.jornadaId.isEmpty else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -12,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )
        }

        guard partido.equipoA != partido.equipoB else {
            return NSError(
                domain: "RegisterMatchesUseCase",
                code: -13,
                userInfo: [NSLocalizedDescriptionKey: "Un equipo no puede jugar contra sí mismo"]
            )
        }

        return nil
    }
}
