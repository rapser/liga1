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

    // MARK: - Sanciones de puntos (solo acumulado)

    func test_execute_addsNegativeSanctionsAndReordersTable() {
        let apertura = [
            Team(nombre: "Sport Boys", logo: "sba", partidosJugados: 17, puntos: 20),
            Team(nombre: "Atlético Grau", logo: "gra", partidosJugados: 17, puntos: 18)
        ]
        let clausura = [
            Team(nombre: "Sport Boys", logo: "sba", partidosJugados: 15, puntos: 25),
            Team(nombre: "Atlético Grau", logo: "gra", partidosJugados: 16, puntos: 25)
        ]

        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: apertura,
            clausura: clausura,
            sanctions: [
                PointSanction(teamCode: "sba", points: -3, resolution: "Res. 082-CL-LFPP-2026"),
                PointSanction(teamCode: "sba", points: -1, resolution: "Res. 088-CL-LFPP-2026")
            ]
        )

        XCTAssertEqual(result.map(\.logo), ["gra", "sba"])
        XCTAssertEqual(result.last?.puntos, 41)
    }

    func test_execute_ignoresSanctionsForUnknownTeamsAndNonNegativeValues() {
        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: [Team(nombre: "UTC", logo: "utc", partidosJugados: 1, puntos: 3)],
            clausura: [],
            sanctions: [
                PointSanction(teamCode: "xyz", points: -5, resolution: ""),
                PointSanction(teamCode: "utc", points: 2, resolution: "")
            ]
        )

        XCTAssertEqual(result.first?.puntos, 3)
    }

    func test_execute_beforeAnyMatch_keepsZeroPointsAndAlphabeticalOrder() {
        let result = CalculateAccumulatedStandingsUseCase().execute(
            apertura: [Team(nombre: "UTC", logo: "utc"), Team(nombre: "Alianza", logo: "ali")],
            clausura: [],
            sanctions: [PointSanction(teamCode: "utc", points: -10, resolution: "")]
        )

        XCTAssertEqual(result.map(\.nombre), ["Alianza", "UTC"])
        XCTAssertEqual(result.last?.puntos, 0)
    }
}
