import XCTest
@testable import liga1

final class SimulateStandingsUseCaseTests: XCTestCase {

    private var sut: SimulateStandingsUseCase!

    override func setUp() {
        super.setUp()
        sut = SimulateStandingsUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func row(_ table: [Team], _ code: String) -> Team {
        table.first { $0.logo == code }!
    }

    // MARK: - Aplicación de resultados

    func test_homeWin_updatesBothRows() {
        let base = [
            Team.standing(code: "ali", pts: 10, pj: 5, pg: 3, pe: 1, pp: 1, gf: 9, gc: 5),
            Team.standing(code: "uni", pts: 8, pj: 5, pg: 2, pe: 2, pp: 1, gf: 6, gc: 4)
        ]
        let table = sut.execute(base: base, predictions: [
            .init(homeCode: "ali", awayCode: "uni", homeGoals: 2, awayGoals: 0)
        ])

        let ali = row(table, "ali")
        XCTAssertEqual(ali.puntos, 13)
        XCTAssertEqual(ali.partidosJugados, 6)
        XCTAssertEqual(ali.partidosGanados, 4)
        XCTAssertEqual(ali.golesFavor, 11)
        XCTAssertEqual(ali.golesContra, 5)
        XCTAssertEqual(ali.diferenciaGoles, 6)

        let uni = row(table, "uni")
        XCTAssertEqual(uni.puntos, 8)
        XCTAssertEqual(uni.partidosPerdidos, 2)
        XCTAssertEqual(uni.golesContra, 6)
        XCTAssertEqual(uni.diferenciaGoles, 0) // base +2 (6-4), concede 2 ⇒ 6-6
    }

    func test_draw_addsOnePointEach() {
        let base = [
            Team.standing(code: "cri", pts: 7),
            Team.standing(code: "mel", pts: 7)
        ]
        let table = sut.execute(base: base, predictions: [
            .init(homeCode: "cri", awayCode: "mel", homeGoals: 1, awayGoals: 1)
        ])
        XCTAssertEqual(row(table, "cri").puntos, 8)
        XCTAssertEqual(row(table, "mel").puntos, 8)
        XCTAssertEqual(row(table, "cri").partidosEmpatados, 1)
    }

    func test_multiplePredictions_accumulate() {
        let base = [
            Team.standing(code: "ali", pts: 0),
            Team.standing(code: "uni", pts: 0),
            Team.standing(code: "cri", pts: 0)
        ]
        let table = sut.execute(base: base, predictions: [
            .init(homeCode: "ali", awayCode: "uni", homeGoals: 1, awayGoals: 0),
            .init(homeCode: "ali", awayCode: "cri", homeGoals: 3, awayGoals: 3),
            .init(homeCode: "cri", awayCode: "uni", homeGoals: 0, awayGoals: 2)
        ])
        XCTAssertEqual(row(table, "ali").puntos, 4)   // 3 + 1
        XCTAssertEqual(row(table, "uni").puntos, 3)   // 0 + 3
        XCTAssertEqual(row(table, "cri").puntos, 1)   // 1 + 0
        XCTAssertEqual(row(table, "ali").partidosJugados, 2)
    }

    func test_predictionForUnknownTeam_isIgnored() {
        let base = [Team.standing(code: "ali", pts: 5)]
        let table = sut.execute(base: base, predictions: [
            .init(homeCode: "ali", awayCode: "xxx", homeGoals: 2, awayGoals: 0)
        ])
        XCTAssertEqual(row(table, "ali").puntos, 5)
        XCTAssertEqual(row(table, "ali").partidosJugados, 0)
    }

    func test_pureFunction_doesNotMutateInput() {
        let base = [
            Team.standing(code: "ali", pts: 10),
            Team.standing(code: "uni", pts: 10)
        ]
        _ = sut.execute(base: base, predictions: [
            .init(homeCode: "ali", awayCode: "uni", homeGoals: 5, awayGoals: 0)
        ])
        XCTAssertEqual(base[0].puntos, 10)
        XCTAssertEqual(base[0].partidosJugados, 0)
    }

    // MARK: - Orden y desempates Liga 1 (pts > DG > GF > PG > nombre)

    func test_sort_byPoints() {
        let base = [
            Team.standing(code: "a", pts: 5),
            Team.standing(code: "b", pts: 9),
            Team.standing(code: "c", pts: 7)
        ]
        let table = sut.execute(base: base, predictions: [])
        XCTAssertEqual(table.map(\.logo), ["b", "c", "a"])
    }

    func test_tiebreak_goalDifferenceBeatsGoalsFor() {
        let base = [
            Team.standing(code: "a", pts: 10, gf: 10, gc: 8), // DG +2
            Team.standing(code: "b", pts: 10, gf: 20, gc: 15) // DG +5, más GF pero...
        ]
        let table = sut.execute(base: base, predictions: [])
        XCTAssertEqual(table.map(\.logo), ["b", "a"]) // gana mejor DG
    }

    func test_tiebreak_goalsForWhenSamePointsAndDiff() {
        let base = [
            Team.standing(code: "a", pts: 10, gf: 12, gc: 10), // DG +2, GF 12
            Team.standing(code: "b", pts: 10, gf: 18, gc: 16)  // DG +2, GF 18
        ]
        let table = sut.execute(base: base, predictions: [])
        XCTAssertEqual(table.map(\.logo), ["b", "a"])
    }

    func test_tiebreak_winsWhenSamePointsDiffAndGoalsFor() {
        let base = [
            Team.standing(code: "a", pts: 10, pg: 3, gf: 10, gc: 8),
            Team.standing(code: "b", pts: 10, pg: 5, gf: 10, gc: 8)
        ]
        let table = sut.execute(base: base, predictions: [])
        XCTAssertEqual(table.map(\.logo), ["b", "a"])
    }

    func test_tiebreak_fallsBackToName() {
        let base = [
            Team(nombre: "Zeta", ciudad: "", logo: "z", puntos: 10),
            Team(nombre: "Alfa", ciudad: "", logo: "a", puntos: 10)
        ]
        let table = sut.execute(base: base, predictions: [])
        XCTAssertEqual(table.map(\.logo), ["a", "z"])
    }

    func test_predictionCanFlipOrder_frontieraDescenso() {
        // 'x' está último; si gana su partido pendiente supera a 'w'.
        let base = [
            Team.standing(code: "w", pts: 20, gf: 20, gc: 20),
            Team.standing(code: "x", pts: 18, gf: 18, gc: 22)
        ]
        let before = sut.execute(base: base, predictions: [])
        XCTAssertEqual(before.map(\.logo), ["w", "x"])

        let after = sut.execute(base: base, predictions: [
            .init(homeCode: "x", awayCode: "w", homeGoals: 3, awayGoals: 0)
        ])
        XCTAssertEqual(after.map(\.logo), ["x", "w"]) // x: 21 pts, DG +? supera
    }
}
