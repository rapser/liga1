// MockJornadasRepository.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockJornadasRepository: JornadasRepositoryProtocol {

    var fetchResult: Result<[Jornada], Error> = .success([])
    var fetchCallCount = 0

    private let observeSubject = CurrentValueSubject<[Jornada], Never>([])
    var observeCallCount = 0

    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error> {
        fetchCallCount += 1
        switch fetchResult {
        case .success(let jornadas):
            return Just(jornadas).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never> {
        observeCallCount += 1
        return observeSubject.eraseToAnyPublisher()
    }

    func sendObservedJornadas(_ jornadas: [Jornada]) {
        observeSubject.send(jornadas)
    }
}
