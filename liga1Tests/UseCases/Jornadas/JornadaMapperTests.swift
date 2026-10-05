// JornadaMapperTests.swift
// liga1Tests

import XCTest
import FirebaseFirestore
@testable import liga1

final class JornadaMapperTests: XCTestCase {

    func test_toDomain_readsHorariosConfirmadosAndFechaFin() {
        let fin = limaDate(year: 2026, month: 10, day: 29, hour: 19, minute: 30)
        let dto = JornadaDTO(
            numero: nil,
            torneo: nil,
            fechaInicio: Timestamp(date: limaDate(year: 2026, month: 10, day: 27, hour: 15)),
            fechaFin: Timestamp(date: fin),
            horariosConfirmados: true
        )

        let jornada = JornadaMapper.toDomain(from: dto, documentID: "clausura_14", logger: MockLogger())

        XCTAssertEqual(jornada?.id, "clausura_14")
        XCTAssertEqual(jornada?.torneo, "clausura")
        XCTAssertEqual(jornada?.numero, 14)
        XCTAssertEqual(jornada?.horariosConfirmados, true)
        XCTAssertEqual(jornada?.fechaFin, fin)
    }

    func test_toDomain_withoutHorariosConfirmados_defaultsToFalse() {
        let dto = JornadaDTO(numero: 3, torneo: "apertura", fechaInicio: nil)

        let jornada = JornadaMapper.toDomain(from: dto, documentID: "apertura_03", logger: MockLogger())

        XCTAssertEqual(jornada?.horariosConfirmados, false)
        XCTAssertNil(jornada?.fechaFin)
    }

    func test_toDomain_withoutNumberAndTorneo_infersThemFromDocumentID() {
        let dto = JornadaDTO(numero: nil, torneo: nil, fechaInicio: nil, horariosConfirmados: true)

        let jornada = JornadaMapper.toDomain(from: dto, documentID: "clausura_15", logger: MockLogger())

        XCTAssertEqual(jornada?.torneo, "clausura")
        XCTAssertEqual(jornada?.numero, 15)
    }
}
