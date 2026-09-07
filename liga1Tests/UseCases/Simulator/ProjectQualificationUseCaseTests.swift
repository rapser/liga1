import XCTest
@testable import liga1

final class ProjectQualificationUseCaseTests: XCTestCase {

    private var sut: ProjectQualificationUseCase!

    override func setUp() {
        super.setUp()
        sut = ProjectQualificationUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// Tabla ordenada de `count` equipos con códigos "t1"..."tN".
    private func table(_ count: Int) -> [Team] {
        (1...count).map { Team.standing(code: "t\($0)", pts: (count - $0) * 3) }
    }

    func test_liga1Bands_onEighteenTeams() {
        let zones = sut.execute(table: table(18), rules: .liga1)

        XCTAssertEqual(zones["t1"], .libertadores)
        XCTAssertEqual(zones["t2"], .libertadores)
        XCTAssertEqual(zones["t3"], .libertadoresPrevia)
        XCTAssertEqual(zones["t4"], .libertadoresPrevia)
        XCTAssertEqual(zones["t5"], .sudamericana)
        XCTAssertEqual(zones["t7"], .sudamericana)
        XCTAssertEqual(zones["t8"], QualificationZone.none)
        XCTAssertEqual(zones["t15"], QualificationZone.none)
        XCTAssertEqual(zones["t16"], .descenso)
        XCTAssertEqual(zones["t17"], .descenso)
        XCTAssertEqual(zones["t18"], .descenso)
    }

    func test_descensoBand_scalesWithTableSize() {
        let zones = sut.execute(table: table(10), rules: .liga1)
        XCTAssertEqual(zones["t8"], .descenso)  // últimos 3 de 10
        XCTAssertEqual(zones["t9"], .descenso)
        XCTAssertEqual(zones["t10"], .descenso)
        XCTAssertEqual(zones["t7"], .sudamericana)
    }

    func test_descensoTakesPrecedenceOverCupBands_whenTableTooSmall() {
        // Con 4 equipos, últimos 3 descienden ⇒ solo el 1º se salva.
        let zones = sut.execute(table: table(4), rules: .liga1)
        XCTAssertEqual(zones["t1"], .libertadores)
        XCTAssertEqual(zones["t2"], .descenso)
        XCTAssertEqual(zones["t3"], .descenso)
        XCTAssertEqual(zones["t4"], .descenso)
    }

    func test_customRules_withoutPrevia() {
        let rules = QualificationRules(
            libertadores: 1...1,
            libertadoresPrevia: nil,
            sudamericana: 2...3,
            descensoUltimos: 2
        )
        let zones = sut.execute(table: table(8), rules: rules)
        XCTAssertEqual(zones["t1"], .libertadores)
        XCTAssertEqual(zones["t2"], .sudamericana)
        XCTAssertEqual(zones["t3"], .sudamericana)
        XCTAssertEqual(zones["t4"], QualificationZone.none)
        XCTAssertEqual(zones["t7"], .descenso)
        XCTAssertEqual(zones["t8"], .descenso)
    }

    func test_emptyTable_returnsEmpty() {
        XCTAssertTrue(sut.execute(table: [], rules: .liga1).isEmpty)
    }

    func test_keyedByTeamCode() {
        let zones = sut.execute(table: [Team.standing(code: "ali", pts: 30)], rules: .liga1)
        XCTAssertNotNil(zones["ali"])
    }
}
