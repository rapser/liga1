// MockLogoutUseCase.swift
// liga1Tests

import Combine
import Foundation
@testable import liga1

final class MockLogoutUseCase: LogoutUseCaseProtocol {

    var result: Result<Void, Error> = .success(())
    var executeCallCount = 0

    func execute() -> AnyPublisher<Void, Error> {
        executeCallCount += 1
        return result.publisher.eraseToAnyPublisher()
    }
}
