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

    func test_start_activeEnabled_observesClausuraWithoutOneShotFetch() {
        let repository = MockTeamsRepository()
        let sut = makeSUT(repository: repository)

        sut.start()

        XCTAssertEqual(repository.observedTorneos, [.clausura])
        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    func test_loadSameTorneoTwice_reusesTheListener() {
        let repository = MockTeamsRepository()
        let sut = makeSUT(repository: repository)

        sut.loadTeams(for: .clausura)
        sut.loadTeams(for: .clausura)

        XCTAssertEqual(repository.observedTorneos, [.clausura])
    }

    func test_loadAcumulado_readsAcumuladoCollectionAndMarksSanctionedTeams() {
        let repository = MockTeamsRepository()
        repository.observedTeams = [.acumulado: [
            Team(nombre: "Alianza Lima", logo: "ali", partidosJugados: 32, puntos: 68),
            Team(nombre: "UTC", logo: "utc", partidosJugados: 32, puntos: 13)
        ]]
        repository.pointSanctions = [
            PointSanction(teamCode: "utc", points: -10, resolution: "Res. 014-CCRD-FPF-2024")
        ]
        let sut = makeSUT(repository: repository)
        let expectation = expectation(description: "acumulado")
        sut.$displayedTeams
            .dropFirst()
            .first()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.loadTeams(for: .acumulado)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(repository.observedTorneos, [.acumulado])
        // Los puntos vienen tal cual de la colección (ya con la sanción); no se resta otra vez.
        XCTAssertEqual(sut.displayedTeams.map(\.puntos), [68, 13])
        XCTAssertEqual(sut.displayedTeams.map(\.hasPointSanction), [false, true])
        XCTAssertEqual(sut.sanctionNotes, [
            SanctionNoteUI(teamCode: "utc", teamName: "UTC", points: -10, resolution: "Res. 014-CCRD-FPF-2024")
        ])
    }

    func test_loadClausura_doesNotObserveSanctions() {
        let repository = MockTeamsRepository()
        repository.pointSanctions = [PointSanction(teamCode: "utc", points: -10, resolution: "")]
        let sut = makeSUT(repository: repository)

        sut.loadTeams(for: .clausura)

        XCTAssertEqual(repository.observePointSanctionsCallCount, 0)
        XCTAssertTrue(sut.sanctionNotes.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        repository: MockTeamsRepository = MockTeamsRepository(),
        activeEnabled: Bool = true,
        remoteEnabled: Bool = true
    ) -> TorneoViewModel {
        TorneoViewModel(
            fetchTeamsUseCase: FetchTeamsUseCase(repository: repository),
            tournamentAvailabilityUseCase: MockTournamentAvailabilityUseCase(
                activeEnabled: activeEnabled,
                remoteEnabled: remoteEnabled
            )
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
