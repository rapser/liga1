// MockMatchesRepository.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockMatchesRepository: MatchesRepositoryProtocol {

    var fetchResult: Result<[Match], Error> = .success([])
    /// Resultado por jornada; si falta la clave se usa `fetchResult`.
    var resultsByJornada: [String: [Match]] = [:]
    var fetchCallCount = 0
    var lastFetchedJornadaId: String?

    private var observeSubjects: [String: CurrentValueSubject<[Match], Never>] = [:]
    var observeCallCount = 0

    func fetchMatches(for jornadaId: String) -> AnyPublisher<[Match], Error> {
        fetchCallCount += 1
        lastFetchedJornadaId = jornadaId
        if let matches = resultsByJornada[jornadaId] {
            return Just(matches).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        switch fetchResult {
        case .success(let matches):
            return Just(matches).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func observeMatches(for jornadaId: String) -> AnyPublisher<[Match], Never> {
        observeCallCount += 1
        if observeSubjects[jornadaId] == nil {
            observeSubjects[jornadaId] = CurrentValueSubject([])
        }
        return observeSubjects[jornadaId]!.eraseToAnyPublisher()
    }

    func sendObservedMatches(_ matches: [Match], for jornadaId: String) {
        if observeSubjects[jornadaId] == nil {
            observeSubjects[jornadaId] = CurrentValueSubject([])
        }
        observeSubjects[jornadaId]!.send(matches)
    }
}
