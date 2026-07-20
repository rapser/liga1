import XCTest
import Combine
@testable import liga1

final class TorneoViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_init_activeDisabled_exposesOnlyAperturaImmediately() {
        let sut = makeSUT(activeEnabled: false, remoteEnabled: false)

        XCTAssertEqual(sut.availableTorneos, [.apertura])
        XCTAssertEqual(sut.selectedTorneo, .apertura)
    }

    func test_init_activeEnabled_exposesAllTablesImmediately() {
        let sut = makeSUT(activeEnabled: true, remoteEnabled: true)

        XCTAssertEqual(sut.availableTorneos, [.apertura, .clausura, .acumulado])
        XCTAssertEqual(sut.selectedTorneo, .clausura)
    }

    func test_refreshAvailability_remoteChange_updatesTables() {
        let sut = makeSUT(activeEnabled: false, remoteEnabled: true)
        let expectation = expectation(description: "availability")

        sut.$availableTorneos
            .dropFirst()
            .sink { torneos in
                XCTAssertEqual(torneos, [.apertura, .clausura, .acumulado])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.refreshTournamentAvailability()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(sut.selectedTorneo, .clausura)
    }

    func test_refreshAvailability_sameValue_doesNotPublishAgain() {
        let sut = makeSUT(activeEnabled: true, remoteEnabled: true)
        let expectation = expectation(description: "no redundant update")
        expectation.isInverted = true

        sut.$availableTorneos
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.refreshTournamentAvailability()
        waitForExpectations(timeout: 0.2)
    }

    func test_start_activeEnabled_loadsClausura() {
        let repository = MockTeamsRepository()
        let sut = TorneoViewModel(
            fetchTeamsUseCase: FetchTeamsUseCase(repository: repository),
            tournamentAvailabilityUseCase: MockTournamentAvailabilityUseCase(
                activeEnabled: true,
                remoteEnabled: true
            ),
            calculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCase()
        )

        sut.start()

        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(repository.lastTorneoRequested, .clausura)
    }

    func test_loadAcumulado_fetchesAperturaAndClausura() {
        let repository = MockTeamsRepository()
        let useCase = FetchTeamsUseCase(repository: repository)
        let sut = TorneoViewModel(
            fetchTeamsUseCase: useCase,
            tournamentAvailabilityUseCase: MockTournamentAvailabilityUseCase(
                activeEnabled: true,
                remoteEnabled: true
            ),
            calculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCase()
        )
        sut.loadTeams(for: .acumulado)

        XCTAssertEqual(repository.fetchCallCount, 2)
        XCTAssertEqual(repository.lastTorneoRequested, .clausura)
    }

    private func makeSUT(activeEnabled: Bool, remoteEnabled: Bool) -> TorneoViewModel {
        TorneoViewModel(
            fetchTeamsUseCase: FetchTeamsUseCase(repository: MockTeamsRepository()),
            tournamentAvailabilityUseCase: MockTournamentAvailabilityUseCase(
                activeEnabled: activeEnabled,
                remoteEnabled: remoteEnabled
            ),
            calculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCase()
        )
    }
}

private struct MockTournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol {
    let activeEnabled: Bool
    let remoteEnabled: Bool

    var activeClausuraEnabled: Bool { activeEnabled }

    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never> {
        Just(remoteEnabled).eraseToAnyPublisher()
    }
}
