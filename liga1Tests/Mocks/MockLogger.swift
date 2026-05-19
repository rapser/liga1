// MockLogger.swift
// liga1Tests

import Foundation
@testable import liga1

final class MockLogger: LoggerProtocol {

    private(set) var errorMessages: [(message: String, error: Error?)] = []
    private(set) var warningMessages: [String] = []
    private(set) var infoMessages: [String] = []
    private(set) var debugMessages: [String] = []

    var errorCallCount: Int { errorMessages.count }

    func error(_ message: String, error: Error?) {
        errorMessages.append((message, error))
    }

    func warning(_ message: String) {
        warningMessages.append(message)
    }

    func info(_ message: String) {
        infoMessages.append(message)
    }

    func debug(_ message: String) {
        debugMessages.append(message)
    }
}
