//
//  FetchMatchesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import Combine

/// Use Case para obtener partidos de una jornada
protocol FetchMatchesUseCaseProtocol {
    func execute(for jornadaId: String) -> AnyPublisher<[Match], Error>
}

class FetchMatchesUseCase: FetchMatchesUseCaseProtocol {

    private let repository: MatchesRepositoryProtocol

    init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for jornadaId: String) -> AnyPublisher<[Match], Error> {
        // Validación de negocio
        guard !jornadaId.isEmpty else {
            Logger.shared.error("FetchMatchesUseCase: jornadaId is empty", error: nil)
            return Fail(error: NSError(
                domain: "FetchMatchesUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )).eraseToAnyPublisher()
        }


        return repository.fetchMatches(for: jornadaId)
            .map { [weak self] matches in
                // Filtrar partidos por fecha más cercana
                return self?.filterMatchesByClosestDate(matches) ?? matches
            }
            .handleEvents(
                receiveOutput: { matches in
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("FetchMatchesUseCase: Failed to fetch matches for jornada \(jornadaId)", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    /// Filtra los partidos para mostrar solo los del día más cercano
    /// - Si ya pasó el día, no se muestran esos partidos
    /// - Solo se muestran los partidos del día más próximo (hoy o futuro)
    private func filterMatchesByClosestDate(_ matches: [Match]) -> [Match] {
        guard !matches.isEmpty else { return [] }

        let now = Date()
        let calendar = Calendar.current

        // Agrupar partidos por día
        let matchesByDate = Dictionary(grouping: matches) { match -> Date in
            // Obtener solo la fecha (sin hora) para agrupar por día
            return calendar.startOfDay(for: match.fecha)
        }

        // Obtener todas las fechas únicas y ordenarlas
        let sortedDates = matchesByDate.keys.sorted()

        // Encontrar la fecha más cercana que sea hoy o futura
        let todayStart = calendar.startOfDay(for: now)

        // Buscar la primera fecha que sea mayor o igual a hoy
        guard let closestDate = sortedDates.first(where: { $0 >= todayStart }) else {
            // Si no hay fechas futuras, retornar vacío (todos los partidos ya pasaron)
            return []
        }

        // Retornar solo los partidos de esa fecha más cercana
        let filteredMatches = matchesByDate[closestDate] ?? []


        return filteredMatches.sorted { $0.fecha < $1.fecha }
    }
}
