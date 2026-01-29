//
//  RegisterMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation
import Combine

protocol RegisterMatchesUseCaseProtocol {
    /// Registra una jornada individual con sus partidos
    func registerJornadaWithMatches(jornadaId: String, mostrar: Bool, fechaInicio: Date, matches: [Match]) -> AnyPublisher<Void, Error>
    
    /// Registra todas las 17 jornadas del torneo Apertura
    func registerAllAperturaJornadas() -> AnyPublisher<Void, Error>
}

final class RegisterMatchesUseCase: RegisterMatchesUseCaseProtocol {

    private let adminMatchRepository: AdminMatchRepositoryProtocol

    init(adminMatchRepository: AdminMatchRepositoryProtocol) {
        self.adminMatchRepository = adminMatchRepository
    }

    func registerJornadaWithMatches(jornadaId: String, mostrar: Bool, fechaInicio: Date, matches: [Match]) -> AnyPublisher<Void, Error> {
        guard !matches.isEmpty else {
            let error = NSError(
                domain: "RegisterMatchesUseCase",
                code: -14,
                userInfo: [NSLocalizedDescriptionKey: "La lista de partidos no puede estar vacía"]
            )
            Logger.shared.error("RegisterMatchesUseCase: Empty matches array for jornada", error: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // Validar cada partido
        for (index, match) in matches.enumerated() {
            if let validationError = validateMatch(match, jornadaId: jornadaId) {
                Logger.shared.error("RegisterMatchesUseCase: Validation failed for match at index \(index) in jornada \(jornadaId)", error: validationError)
                return Fail(error: validationError).eraseToAnyPublisher()
            }
        }
        
        return adminMatchRepository.registerJornadaWithMatches(
            jornadaId: jornadaId,
            mostrar: mostrar,
            fechaInicio: fechaInicio,
            matches: matches
        )
        .handleEvents(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("RegisterMatchesUseCase: Failed to register jornada \(jornadaId)", error: error)
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func registerAllAperturaJornadas() -> AnyPublisher<Void, Error> {
        
        return adminMatchRepository.registerAllAperturaJornadas()
            .handleEvents(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.shared.error("RegisterMatchesUseCase: Failed to register all Apertura jornadas", error: error)
                    case .finished:
                        Logger.shared.info("RegisterMatchesUseCase: Successfully registered all 17 Apertura jornadas")
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
