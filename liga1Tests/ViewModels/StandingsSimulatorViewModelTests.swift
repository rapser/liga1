import XCTest
import Combine
@testable import liga1

final class StandingsSimulatorViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(
        teams: [TorneoType: [Team]] = [:],
        fixtures: [RemainingFixture] = []
    ) -> StandingsSimulatorViewModel {
        StandingsSimulatorViewModel(
            fetchTeamsUseCase: StubFetchTeams(byTorneo: teams),
            calculateAccumulatedUseCase: CalculateAccumulatedStandingsUseCase(),
            fetchRemainingFixturesUseCase: StubFetchRemainingFixtures(fixtures: fixtures),
            simulateStandingsUseCase: SimulateStandingsUseCase(),
            projectQualificationUseCase: ProjectQualificationUseCase()
        )
    }

    private func settle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
    }

    private func fixture(_ id: String, _ home: String, _ away: String, jornada: Int = 1) -> RemainingFixture {
        RemainingFixture(id: id, jornadaId: "clausura_0\(jornada)", jornadaNumero: jornada,
                         homeCode: home, awayCode: away, fecha: Date(timeIntervalSince1970: TimeInterval(jornada)))
    }

    // MARK: - load

    func test_load_populatesFixturesSeededZeroAndProjectedTable() {
        let sut = makeSUT(
            teams: [.clausura: [
                Team.standing(code: "ali", pts: 10, pj: 5, gf: 10, gc: 5),
                Team.standing(code: "uni", pts: 10, pj: 5, gf: 8, gc: 8)
            ]],
            fixtures: [fixture("uni_ali", "uni", "ali")]
        )

        sut.send(.load(.clausura))
        settle()

        XCTAssertFalse(sut.state.isLoading)
        XCTAssertEqual(sut.state.fixtures.count, 1)
        XCTAssertEqual(sut.state.fixtures[0].homeGoals, 0)
        XCTAssertEqual(sut.state.fixtures[0].homeName, "UNI") // homeCode "uni"; Team.standing usa code.uppercased()
        XCTAssertEqual(sut.state.fixtures[0].awayName, "ALI")
        // 0-0 ⇒ empate ⇒ ambos suman 1 y juegan 1 más
        XCTAssertEqual(sut.state.projected.map(\.code), ["ali", "uni"])
        XCTAssertEqual(sut.state.projected[0].pts, 11)
        XCTAssertEqual(sut.state.projected[0].pj, 6)
    }

    func test_setScore_reordersProjectedTableAndComputesDelta() {
        let sut = makeSUT(
            teams: [.clausura: [
                Team.standing(code: "ali", pts: 10, pj: 5, gf: 10, gc: 5),
                Team.standing(code: "uni", pts: 10, pj: 5, gf: 8, gc: 8)
            ]],
            fixtures: [fixture("uni_ali", "uni", "ali")]
        )
        sut.send(.load(.clausura))
        settle()

        sut.send(.setScore(id: "uni_ali", home: 3, away: 0)) // uni gana

        XCTAssertEqual(sut.state.projected.map(\.code), ["uni", "ali"])
        let uni = sut.state.projected.first { $0.code == "uni" }!
        XCTAssertEqual(uni.pts, 13)
        XCTAssertEqual(uni.deltaVsBase, 1)   // sube de 2.º a 1.º
        let ali = sut.state.projected.first { $0.code == "ali" }!
        XCTAssertEqual(ali.deltaVsBase, -1)
    }

    func test_setScore_clampsGoals() {
        let sut = makeSUT(
            teams: [.clausura: [Team.standing(code: "a"), Team.standing(code: "b")]],
            fixtures: [fixture("a_b", "a", "b")]
        )
        sut.send(.load(.clausura))
        settle()

        sut.send(.setScore(id: "a_b", home: -3, away: 99))
        XCTAssertEqual(sut.state.fixtures[0].homeGoals, 0)
        XCTAssertEqual(sut.state.fixtures[0].awayGoals, 20)
    }

    func test_resetScores_returnsAllToZero() {
        let sut = makeSUT(
            teams: [.clausura: [Team.standing(code: "a", pts: 5), Team.standing(code: "b", pts: 5)]],
            fixtures: [fixture("a_b", "a", "b")]
        )
        sut.send(.load(.clausura))
        settle()
        sut.send(.setScore(id: "a_b", home: 4, away: 1))
        XCTAssertEqual(sut.state.fixtures[0].homeGoals, 4)

        sut.send(.resetScores)
        XCTAssertEqual(sut.state.fixtures[0].homeGoals, 0)
        XCTAssertEqual(sut.state.fixtures[0].awayGoals, 0)
    }

    func test_acumulado_sumsAperturaAndClausuraAsBase() {
        let sut = makeSUT(
            teams: [
                .apertura: [Team.standing(code: "ali", pts: 30, pj: 15), Team.standing(code: "uni", pts: 20, pj: 15)],
                .clausura: [Team.standing(code: "ali", pts: 10, pj: 5), Team.standing(code: "uni", pts: 25, pj: 5)]
            ],
            fixtures: []
        )
        sut.send(.load(.acumulado))
        settle()

        // ali 40, uni 45 ⇒ uni primero
        XCTAssertEqual(sut.state.projected.map(\.code), ["uni", "ali"])
        XCTAssertEqual(sut.state.projected.first { $0.code == "uni" }?.pts, 45)
    }

    func test_groupedFixtures_sortedByJornada() {
        let sut = makeSUT(
            teams: [.clausura: [Team.standing(code: "a"), Team.standing(code: "b"), Team.standing(code: "c"), Team.standing(code: "d")]],
            fixtures: [fixture("c_d", "c", "d", jornada: 2), fixture("a_b", "a", "b", jornada: 1)]
        )
        sut.send(.load(.clausura))
        settle()

        XCTAssertEqual(sut.groupedFixtures.map(\.jornada), [1, 2])
        XCTAssertEqual(sut.groupedFixtures.first?.fixtures.map(\.id), ["a_b"])
    }

    func test_load_setsErrorOnFailure() {
        let sut = StandingsSimulatorViewModel(
            fetchTeamsUseCase: StubFetchTeams(byTorneo: [:], error: TestError.network),
            calculateAccumulatedUseCase: CalculateAccumulatedStandingsUseCase(),
            fetchRemainingFixturesUseCase: StubFetchRemainingFixtures(fixtures: []),
            simulateStandingsUseCase: SimulateStandingsUseCase(),
            projectQualificationUseCase: ProjectQualificationUseCase()
        )
        sut.send(.load(.clausura))
        settle()

        XCTAssertNotNil(sut.state.error)
        XCTAssertFalse(sut.state.isLoading)
    }
}

// MARK: - Stubs

private struct StubFetchTeams: FetchTeamsUseCaseProtocol {
    let byTorneo: [TorneoType: [Team]]
    var error: Error?

    func execute(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        if let error { return Fail(error: error).eraseToAnyPublisher() }
        return Just(byTorneo[torneo] ?? []).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func invalidateCache(for torneo: TorneoType?) {}
}

private struct StubFetchRemainingFixtures: FetchRemainingFixturesUseCaseProtocol {
    let fixtures: [RemainingFixture]
    func execute(torneo: TorneoType) -> AnyPublisher<[RemainingFixture], Error> {
        Just(fixtures).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
