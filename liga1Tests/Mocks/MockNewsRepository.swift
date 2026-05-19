// MockNewsRepository.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockNewsRepository: NewsRepositoryProtocol {

    var fetchResult: Result<[NewsItem], Error> = .success([])
    var fetchCallCount = 0

    func fetchNews() -> AnyPublisher<[NewsItem], Error> {
        fetchCallCount += 1
        switch fetchResult {
        case .success(let items):
            return Just(items).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
