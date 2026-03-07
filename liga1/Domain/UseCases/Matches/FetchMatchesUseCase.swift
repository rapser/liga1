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
            return Fail(error: NSError(
                domain: "FetchMatchesUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "El ID de la jornada no puede estar vacío"]
            )).eraseToAnyPublisher()
        }

        return repository.fetchMatches(for: jornadaId)
            .map { [weak self] matches in
                return self?.filterMatchesByClosestDate(matches) ?? matches
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    /// Filtra los partidos para mostrar solo los del día más próximo, bajo estas reglas:
    /// - Se muestra el grupo de partidos del día más cercano que sea HOY o futuro.
    /// - Un partido del día X ya es visible desde el día X-1 (1 día de anticipación natural,
    ///   porque X >= hoy cuando hoy = X-1).
    /// - Si todos los partidos de la jornada ya pasaron, no se muestra ninguno.
    private func filterMatchesByClosestDate(_ matches: [Match]) -> [Match] {
        guard !matches.isEmpty else { return [] }

        let now = Date()
        let calendar = Calendar.current

        // Agrupar partidos por día
        let matchesByDate = Dictionary(grouping: matches) { match -> Date in
            return calendar.startOfDay(for: match.fecha)
        }

        // Obtener todas las fechas únicas y ordenarlas
        let sortedDates = matchesByDate.keys.sorted()

        let todayStart = calendar.startOfDay(for: now)

        // Primera fecha que sea hoy o posterior
        guard let closestDate = sortedDates.first(where: { $0 >= todayStart }) else {
            // Todos los partidos ya pasaron → no mostrar nada
            return []
        }

        return (matchesByDate[closestDate] ?? []).sorted { $0.fecha < $1.fecha }
    }
}
