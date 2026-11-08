import XCTest
@testable import liga1

final class TeamsRepositorySanctionsParsingTests: XCTestCase {

    func test_sanctions_parsesNegativeEntriesAndSkipsInvalidOnes() {
        let data: [String: Any] = [
            "sanctions": [
                ["points": -10, "resolution": "  Res. 014-CCRD-FPF-2024 "],
                ["points": 3, "resolution": "positivo, se ignora"],
                ["resolution": "sin puntos, se ignora"],
                ["points": -1]
            ]
        ]

        let result = TeamsRepository.sanctions(from: data, teamCode: "utc")

        XCTAssertEqual(result, [
            PointSanction(teamCode: "utc", points: -10, resolution: "Res. 014-CCRD-FPF-2024"),
            PointSanction(teamCode: "utc", points: -1, resolution: "")
        ])
    }

    func test_sanctions_withoutField_returnsEmpty() {
        XCTAssertTrue(TeamsRepository.sanctions(from: ["name": "UTC"], teamCode: "utc").isEmpty)
    }
}
