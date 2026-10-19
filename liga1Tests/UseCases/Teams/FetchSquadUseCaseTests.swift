// FetchSquadUseCaseTests.swift
// liga1Tests

import XCTest
@testable import liga1

final class FetchSquadUseCaseTests: XCTestCase {

    private var repository: MockPlayersRepository!
    private var sut: FetchSquadUseCase!

    override func setUp() {
        super.setUp()
        repository = MockPlayersRepository()
        sut = FetchSquadUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_passesTeamIdToRepository() throws {
        _ = try awaitValue(from: sut.execute(teamId: "uni"))

        XCTAssertEqual(repository.lastTeamId, "uni")
    }

    func test_execute_sortsByPositionThenNumber() throws {
        repository.fetchResult = .success([
            .fixture(id: "d", name: "D", number: 4, position: .defender),
            .fixture(id: "f", name: "F", number: 9, position: .forward),
            .fixture(id: "g2", name: "G2", number: 12, position: .goalkeeper),
            .fixture(id: "m", name: "M", number: 8, position: .midfielder),
            .fixture(id: "g1", name: "G1", number: 1, position: .goalkeeper)
        ])

        let result = try awaitValue(from: sut.execute(teamId: "ali"))

        XCTAssertEqual(result.map(\.id), ["g1", "g2", "d", "m", "f"])
    }

    func test_sortedForSquad_playersWithoutNumberGoLastInTheirPosition() {
        let sorted = FetchSquadUseCase.sortedForSquad([
            .fixture(id: "sin", name: "Aaron", number: nil, position: .forward),
            .fixture(id: "once", name: "Zeta", number: 11, position: .forward)
        ])

        XCTAssertEqual(sorted.map(\.id), ["once", "sin"])
    }

    func test_sortedForSquad_sameNumberFallsBackToName() {
        let sorted = FetchSquadUseCase.sortedForSquad([
            .fixture(id: "b", name: "Beto", number: 7, position: .forward),
            .fixture(id: "a", name: "Álvaro", number: 7, position: .forward)
        ])

        XCTAssertEqual(sorted.map(\.id), ["a", "b"])
    }

    func test_execute_propagatesError() throws {
        repository.fetchResult = .failure(TestError.network)

        _ = try awaitFailure(from: sut.execute(teamId: "ali"))
    }
}
