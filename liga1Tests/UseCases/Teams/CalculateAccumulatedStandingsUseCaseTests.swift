import XCTest
@testable import liga1

final class CalculateAccumulatedStandingsUseCaseTests: XCTestCase {

    func test_execute_sumsBothTournamentsByStableTeamId() {
        let apertura = Team(
            nombre: "Alianza Lima",
            logo: "ali",
            partidosJugados: 17,
            partidosGanados: 10,
            golesFavor: 25,
            golesContra: 10,
            diferenciaGoles: 15,
            puntos: 32
        )
        let clausura = Team(
            nombre: "Alianza",
            logo: "ali",
            partidosJugados: 2,
            partidosGanados: 1,
            partidosEmpatados: 1,
            golesFavor: 3,
            golesContra: 1,
            diferenciaGoles: 2,
            puntos: 4
        )

        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: [apertura],
            clausura: [clausura]
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.logo, "ali")
        XCTAssertEqual(result.first?.nombre, "Alianza Lima")
        XCTAssertEqual(result.first?.partidosJugados, 19)
        XCTAssertEqual(result.first?.golesFavor, 28)
        XCTAssertEqual(result.first?.diferenciaGoles, 17)
        XCTAssertEqual(result.first?.puntos, 36)
    }

    func test_execute_includesTeamPresentInOnlyOneTournament() {
        let team = Team(nombre: "Nuevo", logo: "nue", puntos: 3)

        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: [],
            clausura: [team]
        )

        XCTAssertEqual(result, [team])
    }

    func test_execute_whenAllTeamsHaveZeroPoints_ordersAlphabetically() {
        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: [
                Team(nombre: "UTC", logo: "utc"),
                Team(nombre: "Alianza", logo: "ali")
            ],
            clausura: []
        )

        XCTAssertEqual(result.map(\.nombre), ["Alianza", "UTC"])
    }
}
