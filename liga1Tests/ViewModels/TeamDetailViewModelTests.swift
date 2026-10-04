// TeamDetailViewModelTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class TeamDetailViewModelTests: XCTestCase {

    private var repository: MockPlayersRepository!
    private var sut: TeamDetailViewModel!

    override func setUp() {
        super.setUp()
        repository = MockPlayersRepository()
        sut = TeamDetailViewModel(
            team: .fixture(code: "cri", nombre: "Sporting Cristal"),
            fetchSquadUseCase: FetchSquadUseCase(repository: repository)
        )
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    /// El sink de `load()` entrega en la cola principal: se espera al estado en vez de leerlo de inmediato.
    private func loadAndWait(for expected: @escaping (TeamDetailViewModel.State) -> Bool) {
        let exp = expectation(description: "state")
        var cancellable: AnyCancellable?
        cancellable = sut.$state.sink { state in
            if expected(state) {
                exp.fulfill()
                cancellable?.cancel()
            }
        }
        sut.load()
        waitForExpectations(timeout: 2)
        cancellable?.cancel()
    }

    func test_initialState_isLoading() {
        XCTAssertEqual(sut.state, .loading)
    }

    func test_load_usesTeamCodeAsSquadId() {
        loadAndWait { $0 != .loading }

        XCTAssertEqual(repository.lastTeamId, "cri")
    }

    func test_load_groupsPlayersByPositionInSquadOrder() {
        repository.fetchResult = .success([
            .fixture(id: "f", number: 9, position: .forward),
            .fixture(id: "g", number: 1, position: .goalkeeper),
            .fixture(id: "d1", number: 4, position: .defender),
            .fixture(id: "d2", number: 2, position: .defender)
        ])

        loadAndWait { if case .loaded = $0 { return true } else { return false } }

        guard case .loaded(let sections) = sut.state else { return XCTFail("Se esperaba .loaded") }
        XCTAssertEqual(sections.map(\.position), [.goalkeeper, .defender, .forward])
        XCTAssertEqual(sections[1].players.map(\.id), ["d2", "d1"])
    }

    func test_load_emptySquad_isEmptyState() {
        repository.fetchResult = .success([])

        loadAndWait { $0 == .empty }

        XCTAssertEqual(sut.state, .empty)
        XCTAssertNil(sut.photoCredit)
    }

    func test_load_failure_isFailedState() {
        repository.fetchResult = .failure(TestError.network)

        loadAndWait { if case .failed = $0 { return true } else { return false } }

        guard case .failed(let message) = sut.state else { return XCTFail("Se esperaba .failed") }
        XCTAssertFalse(message.isEmpty)
    }

    func test_photoCredit_onlyCountsPlayersWithPhoto() {
        let photo = URL(string: "https://upload.wikimedia.org/p.jpg")
        repository.fetchResult = .success([
            .fixture(id: "a", photoURL: photo, photoCredit: "Wikimedia Commons"),
            .fixture(id: "b", photoURL: nil, photoCredit: "Otra fuente")
        ])

        loadAndWait { if case .loaded = $0 { return true } else { return false } }

        XCTAssertEqual(sut.photoCredit, "Wikimedia Commons")
    }
}
