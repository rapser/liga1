//
//  FetchRemainingFixturesUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol FetchRemainingFixturesUseCaseProtocol {
    /// Partidos `pendiente` del torneo indicado, ordenados por jornada y fecha.
    /// Para `.acumulado` devuelve los pendientes del Clausura (el Apertura ya jugado).
    func execute(torneo: TorneoType) -> AnyPublisher<[RemainingFixture], Error>
}

final class FetchRemainingFixturesUseCase: FetchRemainingFixturesUseCaseProtocol {

    private let jornadasRepository: JornadasRepositoryProtocol
    private let matchesRepository: MatchesRepositoryProtocol

    init(jornadasRepository: JornadasRepositoryProtocol, matchesRepository: MatchesRepositoryProtocol) {
        self.jornadasRepository = jornadasRepository
        self.matchesRepository = matchesRepository
    }

    func execute(torneo: TorneoType) -> AnyPublisher<[RemainingFixture], Error> {
        let prefix = (torneo == .acumulado ? "clausura" : torneo.rawValue) + "_"

        return jornadasRepository.fetchAllJornadas()
            .map { jornadas in jornadas.filter { $0.id.hasPrefix(prefix) } }
            .flatMap { [matchesRepository] jornadas -> AnyPublisher<[RemainingFixture], Error> in
                guard !jornadas.isEmpty else {
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                let streams = jornadas.map { jornada in
                    matchesRepository.fetchMatches(for: jornada.id)
                        .map { matches in
                            matches.compactMap { match -> RemainingFixture? in
                                guard match.estado == .pendiente,
                                      let home = match.equipoLocalId?.trimmingCharacters(in: .whitespaces),
                                      let away = match.equipoVisitanteId?.trimmingCharacters(in: .whitespaces),
                                      !home.isEmpty, !away.isEmpty else { return nil }
                                return RemainingFixture(
                                    id: match.id,
                                    jornadaId: jornada.id,
                                    jornadaNumero: jornada.numero,
                                    homeCode: home,
                                    awayCode: away,
                                    fecha: match.fecha
                                )
                            }
                        }
                        .eraseToAnyPublisher()
                }
                return Publishers.MergeMany(streams)
                    .collect()
                    .map { groups in groups.flatMap { $0 }.sorted(by: RemainingFixture.isOrderedBefore) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
