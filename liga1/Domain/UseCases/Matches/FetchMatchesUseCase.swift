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
    /// Partidos cuyo día de juego en Perú (UTC−5, `America/Lima`) coincide con el de `calendarDay`.
    func execute(for jornadaId: String, calendarDay: Date) -> AnyPublisher<[Match], Error>
}

class FetchMatchesUseCase: FetchMatchesUseCaseProtocol {

    private let repository: MatchesRepositoryProtocol

    init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for jornadaId: String, calendarDay: Date) -> AnyPublisher<[Match], Error> {
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
                guard let self else { return matches }
                return self.filterMatches(on: calendarDay, matches: matches)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    /// Día del calendario en Perú (PET, UTC−5). Los partidos se registran en ese huso; agrupamos por año/mes/día en `America/Lima`.
    private static var limaCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/Lima") ?? .current
        return c
    }

    private static func ymdLima(_ date: Date) -> (Int, Int, Int) {
        let p = limaCalendar.dateComponents([.year, .month, .day], from: date)
        return (p.year ?? 0, p.month ?? 0, p.day ?? 0)
    }

    /// Incluye partidos finalizados: todo el día civil en Perú hasta medianoche; no se ocultan por hora ni por estado.
    private func filterMatches(on day: Date, matches: [Match]) -> [Match] {
        let lima = Self.limaCalendar
        let dayStart = lima.startOfDay(for: day)
        let target = Self.ymdLima(dayStart)
        return matches
            .filter { Self.ymdLima($0.fecha) == target }
            .sorted { $0.fecha < $1.fecha }
    }
}
