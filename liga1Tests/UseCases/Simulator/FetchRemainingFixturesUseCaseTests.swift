import XCTest
import Combine
@testable import liga1

final class FetchRemainingFixturesUseCaseTests: XCTestCase {

    private var jornadas: MockJornadasRepository!
    private var matches: MockMatchesRepository!
    private var sut: FetchRemainingFixturesUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        jornadas = MockJornadasRepository()
        matches = MockMatchesRepository()
        sut = FetchRemainingFixturesUseCase(jornadasRepository: jornadas, matchesRepository: matches)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        matches = nil
        jornadas = nil
        super.tearDown()
    }

    private func match(_ id: String, _ home: String, _ away: String,
                       estado: Match.EstadoMatch = .pendiente, date: Date = Date()) -> Match {
        Match(id: id, equipoLocalId: home, equipoVisitanteId: away, fecha: date, estado: estado)
    }

    private func fetch(_ torneo: TorneoType) throws -> [RemainingFixture] {
        try awaitValue(from: sut.execute(torneo: torneo))
    }

    func test_filtersByTorneoPrefix_andPendingOnly() throws {
        jornadas.fetchAllResult = .success([
            .fixture(id: "clausura_01", torneo: "clausura", numero: 1),
            .fixture(id: "clausura_02", torneo: "clausura", numero: 2),
            .fixture(id: "apertura_15", torneo: "apertura", numero: 15)
        ])
        matches.resultsByJornada = [
            "clausura_01": [
                match("hua_ali", "hua", "ali"),
                match("cri_uni", "cri", "uni", estado: .finalizado) // ignorado
            ],
            "clausura_02": [match("mel_cus", "mel", "cus")],
            "apertura_15": [match("ali_uni", "ali", "uni")] // ignorado (otro torneo)
        ]

        let fixtures = try fetch(.clausura)

        XCTAssertEqual(fixtures.map(\.id), ["hua_ali", "mel_cus"])
        XCTAssertEqual(fixtures.first?.jornadaNumero, 1)
        XCTAssertEqual(fixtures.first?.homeCode, "hua")
    }

    func test_acumulado_usesClausuraFixtures() throws {
        jornadas.fetchAllResult = .success([
            .fixture(id: "clausura_03", torneo: "clausura", numero: 3),
            .fixture(id: "apertura_10", torneo: "apertura", numero: 10)
        ])
        matches.resultsByJornada = [
            "clausura_03": [match("adt_gar", "adt", "gar")],
            "apertura_10": [match("x_y", "x", "y")]
        ]

        let fixtures = try fetch(.acumulado)
        XCTAssertEqual(fixtures.map(\.id), ["adt_gar"])
    }

    func test_sortedByJornadaThenDate() throws {
        let early = Date(timeIntervalSince1970: 1_000)
        let late = Date(timeIntervalSince1970: 2_000)
        jornadas.fetchAllResult = .success([
            .fixture(id: "clausura_02", torneo: "clausura", numero: 2),
            .fixture(id: "clausura_01", torneo: "clausura", numero: 1)
        ])
        matches.resultsByJornada = [
            "clausura_02": [match("c_d", "c", "d", date: early)],
            "clausura_01": [
                match("a_b", "a", "b", date: late),
                match("e_f", "e", "f", date: early)
            ]
        ]

        let fixtures = try fetch(.clausura)
        XCTAssertEqual(fixtures.map(\.id), ["e_f", "a_b", "c_d"]) // J1 (por fecha), luego J2
    }

    func test_noJornadasForTorneo_returnsEmpty() throws {
        jornadas.fetchAllResult = .success([.fixture(id: "apertura_01", torneo: "apertura", numero: 1)])
        let fixtures = try fetch(.clausura)
        XCTAssertTrue(fixtures.isEmpty)
    }

    func test_propagatesJornadasFailure() throws {
        jornadas.fetchAllResult = .failure(TestError.network)
        let error = try awaitFailure(from: sut.execute(torneo: .clausura))
        XCTAssertEqual(error as? TestError, .network)
    }
}
