// PlayerMapperTests.swift
// liga1Tests

import XCTest
@testable import liga1

final class PlayerMapperTests: XCTestCase {

    private func dto(
        name: String? = "Paolo Guerrero",
        shortName: String? = "P. Guerrero",
        number: Int? = 9,
        position: String? = "FW",
        age: Int? = 42,
        photoURL: String? = nil,
        photoCredit: String? = nil
    ) -> PlayerDTO {
        PlayerDTO(
            name: name, shortName: shortName, number: number, position: position,
            age: age, photoURL: photoURL, photoCredit: photoCredit, active: true
        )
    }

    func test_toDomain_mapsAllFields() {
        let player = PlayerMapper.toDomain(
            from: dto(photoURL: "https://upload.wikimedia.org/p.jpg", photoCredit: "Wikimedia Commons"),
            id: "espn_1"
        )

        XCTAssertEqual(player?.id, "espn_1")
        XCTAssertEqual(player?.name, "Paolo Guerrero")
        XCTAssertEqual(player?.shortName, "P. Guerrero")
        XCTAssertEqual(player?.number, 9)
        XCTAssertEqual(player?.position, .forward)
        XCTAssertEqual(player?.age, 42)
        XCTAssertEqual(player?.photoURL?.absoluteString, "https://upload.wikimedia.org/p.jpg")
        XCTAssertEqual(player?.photoCredit, "Wikimedia Commons")
    }

    func test_toDomain_positionCodes() {
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(position: "GK"), id: "a")?.position, .goalkeeper)
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(position: "DF"), id: "a")?.position, .defender)
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(position: "MF"), id: "a")?.position, .midfielder)
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(position: "fw"), id: "a")?.position, .forward)
    }

    func test_toDomain_missingNameOrUnknownPosition_returnsNil() {
        XCTAssertNil(PlayerMapper.toDomain(from: dto(name: nil), id: "a"))
        XCTAssertNil(PlayerMapper.toDomain(from: dto(name: "  "), id: "a"))
        XCTAssertNil(PlayerMapper.toDomain(from: dto(position: nil), id: "a"))
        XCTAssertNil(PlayerMapper.toDomain(from: dto(position: "XX"), id: "a"))
    }

    func test_toDomain_missingShortName_fallsBackToName() {
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(shortName: nil), id: "a")?.shortName, "Paolo Guerrero")
        XCTAssertEqual(PlayerMapper.toDomain(from: dto(shortName: ""), id: "a")?.shortName, "Paolo Guerrero")
    }

    func test_toDomain_rejectsNonHttpsPhotoURL() {
        XCTAssertNil(PlayerMapper.toDomain(from: dto(photoURL: "http://example.com/p.jpg"), id: "a")?.photoURL)
        XCTAssertNil(PlayerMapper.toDomain(from: dto(photoURL: ""), id: "a")?.photoURL)
        XCTAssertNil(PlayerMapper.toDomain(from: dto(photoURL: nil), id: "a")?.photoURL)
    }
}
