import XCTest
import Combine
@testable import liga1

final class GetTournamentAvailabilityUseCaseTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_activeClausuraEnabled_returnsRepositoryValue() {
        let repository = MockTournamentConfigRepository(activeValue: true, refreshedValue: true)
        let sut = GetTournamentAvailabilityUseCase(repository: repository)

        XCTAssertTrue(sut.activeClausuraEnabled)
    }

    func test_refreshClausuraEnabled_delegatesToRepository() {
        let repository = MockTournamentConfigRepository(activeValue: false, refreshedValue: true)
        let sut = GetTournamentAvailabilityUseCase(repository: repository)
        let expectation = expectation(description: "refreshed value")

        sut.refreshClausuraEnabled()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(repository.refreshCallCount, 1)
    }
}

private final class MockTournamentConfigRepository: TournamentConfigRepositoryProtocol {
    let activeClausuraEnabled: Bool
    let refreshedValue: Bool
    private(set) var refreshCallCount = 0

    init(activeValue: Bool, refreshedValue: Bool) {
        self.activeClausuraEnabled = activeValue
        self.refreshedValue = refreshedValue
    }

    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never> {
        refreshCallCount += 1
        return Just(refreshedValue).eraseToAnyPublisher()
    }
}
