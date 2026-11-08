import XCTest
@testable import liga1

final class CountryFlagTests: XCTestCase {

    func test_emoji_supportsFifaAndIsoCodes() {
        XCTAssertEqual(CountryFlag.emoji(for: "PER"), "🇵🇪")
        XCTAssertEqual(CountryFlag.emoji(for: "CHI"), "🇨🇱")
        XCTAssertEqual(CountryFlag.emoji(for: "CHL"), "🇨🇱")
        XCTAssertEqual(CountryFlag.emoji(for: "URU"), "🇺🇾")
        XCTAssertEqual(CountryFlag.emoji(for: "pse"), "🇵🇸")
        XCTAssertEqual(CountryFlag.emoji(for: "AR"), "🇦🇷")
    }

    func test_emoji_unknownOrEmpty_returnsNil() {
        XCTAssertNil(CountryFlag.emoji(for: "XYZ"))
        XCTAssertNil(CountryFlag.emoji(for: ""))
        XCTAssertNil(CountryFlag.emoji(for: nil))
    }

    func test_allNationalitiesInFirestore_haveAFlag() {
        // Códigos presentes en equipos/{code}/players (nov. 2026).
        for code in ["PER", "ECU", "ARG", "COL", "CHI", "URU", "PAR", "MEX", "USA", "VEN", "PAN", "BOL", "BRA", "KOR", "PSE"] {
            XCTAssertNotNil(CountryFlag.emoji(for: code), code)
        }
    }

    func test_name_inSpanish() {
        XCTAssertEqual(CountryFlag.name(for: "PER"), "Perú")
        XCTAssertEqual(CountryFlag.name(for: "URU"), "Uruguay")
    }
}
