// XCTestCase+Combine.swift
// liga1Tests

import Combine
import XCTest

extension XCTestCase {

    /// Espera el primer valor de un publisher que puede fallar.
    /// Lanza si el publisher falla o si se agota el timeout.
    @discardableResult
    func awaitValue<T, E: Error>(
        from publisher: AnyPublisher<T, E>,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        var result: Result<T, Error>?
        let expectation = expectation(description: "awaitValue")
        var cancellable: AnyCancellable?
        cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                    expectation.fulfill()
                }
                cancellable = nil
            },
            receiveValue: { value in
                result = .success(value)
                expectation.fulfill()
            }
        )
        waitForExpectations(timeout: timeout, handler: nil)
        return try XCTUnwrap(result, "Publisher emitted no value", file: file, line: line).get()
    }

    /// Espera el primer valor de un publisher infallible (Never).
    @discardableResult
    func awaitFirstValue<T>(
        from publisher: AnyPublisher<T, Never>,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T? {
        var received: T?
        let expectation = expectation(description: "awaitFirstValue")
        var cancellable: AnyCancellable?
        cancellable = publisher.sink { value in
            received = value
            expectation.fulfill()
            cancellable = nil
        }
        waitForExpectations(timeout: timeout, handler: nil)
        return received
    }

    /// Espera que un publisher complete (con o sin error).
    /// Lanza si el publisher falla.
    func awaitCompletion<T, E: Error>(
        of publisher: AnyPublisher<T, E>,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        var completionError: Error?
        let expectation = expectation(description: "awaitCompletion")
        var cancellable: AnyCancellable?
        cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    completionError = error
                }
                expectation.fulfill()
                cancellable = nil
            },
            receiveValue: { _ in }
        )
        waitForExpectations(timeout: timeout, handler: nil)
        if let error = completionError { throw error }
    }

    /// Espera que un publisher falle y devuelve el error.
    func awaitFailure<T, E: Error>(
        from publisher: AnyPublisher<T, E>,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> E {
        var receivedError: E?
        let expectation = expectation(description: "awaitFailure")
        var cancellable: AnyCancellable?
        cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                    expectation.fulfill()
                }
                cancellable = nil
            },
            receiveValue: { _ in }
        )
        waitForExpectations(timeout: timeout, handler: nil)
        return try XCTUnwrap(receivedError, "Publisher did not fail", file: file, line: line)
    }
}
