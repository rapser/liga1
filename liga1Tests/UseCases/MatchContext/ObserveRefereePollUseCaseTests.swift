import XCTest
import Combine
@testable import liga1

final class ObserveRefereePollUseCaseTests: XCTestCase {

    private var repository: MockPollRepository!
    private var sut: ObserveRefereePollUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        repository = MockPollRepository()
        sut = ObserveRefereePollUseCase(repository: repository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_delegatesTrimmedMatchIdToRepository() {
        sut.execute(matchId: "  hua_ali ")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(repository.observeActivePollCallCount, 1)
        XCTAssertEqual(repository.lastMatchId, "hua_ali")
    }

    func test_execute_withEmptyMatchId_returnsNilWithoutHittingRepository() {
        let exp = expectation(description: "value")
        sut.execute(matchId: "   ")
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                XCTAssertNil(value)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(repository.observeActivePollCallCount, 0)
    }

    func test_execute_emitsPollFromRepository() {
        let poll = RefereePoll.fixture()
        var received: RefereePoll?
        sut.execute(matchId: "hua_ali")
            .sink(receiveCompletion: { _ in }, receiveValue: { received = $0 })
            .store(in: &cancellables)

        repository.activePollSubject.send(poll)
        XCTAssertEqual(received, poll)
    }
}
