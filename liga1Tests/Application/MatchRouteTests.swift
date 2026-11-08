import XCTest
@testable import liga1

final class MatchRouteTests: XCTestCase {

    func test_init_visibleGoalPayload_usesSnakeCaseKeys() {
        let route = MatchRoute(userInfo: [
            "event_type": "goal",
            "match_id": "cri_mel",
            "jornada_id": "clausura_15"
        ])

        XCTAssertEqual(route, MatchRoute(matchId: "cri_mel", jornadaId: "clausura_15"))
        XCTAssertEqual(route?.torneo, "clausura")
        XCTAssertEqual(route?.jornadaNumero, 15)
    }

    func test_init_silentPayload_usesCamelCaseKeys() {
        let route = MatchRoute(userInfo: ["matchId": "ali_uni", "jornadaId": "apertura_03"])

        XCTAssertEqual(route?.matchId, "ali_uni")
        XCTAssertEqual(route?.jornadaNumero, 3)
    }

    func test_init_missingOrEmptyIds_returnsNil() {
        XCTAssertNil(MatchRoute(userInfo: ["match_id": "ali_uni"]))
        XCTAssertNil(MatchRoute(userInfo: ["match_id": "", "jornada_id": "clausura_15"]))
        XCTAssertNil(MatchRoute(userInfo: [:]))
    }
}
