import XCTest
@testable import liga1

final class SanctionNoteUITests: XCTestCase {

    func test_make_sortsByMostPointsDeductedAndUsesTeamNames() {
        let notes = SanctionNoteUI.make(
            from: [
                PointSanction(teamCode: "adt", points: -1, resolution: "R1"),
                PointSanction(teamCode: "utc", points: -10, resolution: "R2")
            ],
            teams: [Team(nombre: "ADT", logo: "adt"), Team(nombre: "UTC", logo: "utc")]
        )

        XCTAssertEqual(notes.map(\.teamCode), ["utc", "adt"])
        XCTAssertEqual(notes.first?.pointsText, "-10 pts")
    }

    func test_legendSummary_countsDistinctTeams() {
        let notes = [
            SanctionNoteUI(teamCode: "sba", teamName: "Sport Boys", points: -3, resolution: ""),
            SanctionNoteUI(teamCode: "sba", teamName: "Sport Boys", points: -1, resolution: ""),
            SanctionNoteUI(teamCode: "utc", teamName: "UTC", points: -10, resolution: "")
        ]

        XCTAssertEqual(notes.legendSummary, "2 equipos con descuento de puntos")
        XCTAssertEqual(Array(notes.prefix(1)).legendSummary, "1 equipo con descuento de puntos")
    }
}
