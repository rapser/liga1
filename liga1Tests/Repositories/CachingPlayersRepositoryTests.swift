// CachingPlayersRepositoryTests.swift
// liga1Tests

import XCTest
@testable import liga1

final class CachingPlayersRepositoryTests: XCTestCase {

    private var inner: MockPlayersRepository!
    private var sut: CachingPlayersRepository!

    override func setUp() {
        super.setUp()
        inner = MockPlayersRepository()
        sut = CachingPlayersRepository(wrapping: inner)
    }

    override func tearDown() {
        sut = nil
        inner = nil
        super.tearDown()
    }

    func test_firstCall_delegatesToInner() throws {
        inner.fetchResult = .success([.fixture()])

        _ = try awaitValue(from: sut.fetchSquad(teamId: "ali"))

        XCTAssertEqual(inner.fetchCallCount, 1)
    }

    func test_secondCall_sameTeam_usesCache() throws {
        inner.fetchResult = .success([.fixture(id: "a")])
        _ = try awaitValue(from: sut.fetchSquad(teamId: "ali"))

        let cached = try awaitValue(from: sut.fetchSquad(teamId: "ali"))

        XCTAssertEqual(inner.fetchCallCount, 1)
        XCTAssertEqual(cached.map(\.id), ["a"])
    }

    func test_differentTeams_areCachedSeparately() throws {
        _ = try awaitValue(from: sut.fetchSquad(teamId: "ali"))
        _ = try awaitValue(from: sut.fetchSquad(teamId: "uni"))

        XCTAssertEqual(inner.fetchCallCount, 2)
    }

    func test_failure_isNotCached() throws {
        inner.fetchResult = .failure(TestError.network)
        _ = try awaitFailure(from: sut.fetchSquad(teamId: "ali"))

        inner.fetchResult = .success([.fixture()])
        _ = try awaitValue(from: sut.fetchSquad(teamId: "ali"))

        XCTAssertEqual(inner.fetchCallCount, 2)
    }
}
