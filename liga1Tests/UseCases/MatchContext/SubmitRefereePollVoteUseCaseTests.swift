import XCTest
@testable import liga1

final class SubmitRefereePollVoteUseCaseTests: XCTestCase {

    private var repository: MockPollRepository!
    private var auth: MockAuthService!
    private var sut: SubmitRefereePollVoteUseCase!

    override func setUp() {
        super.setUp()
        repository = MockPollRepository()
        auth = MockAuthService()
        sut = SubmitRefereePollVoteUseCase(repository: repository, authService: auth)
    }

    override func tearDown() {
        sut = nil
        auth = nil
        repository = nil
        super.tearDown()
    }

    private func signIn() {
        auth.sendAuthState(.fixture(id: "user-123"))
    }

    func test_execute_whenNotSignedIn_failsWithoutHittingRepository() throws {
        let error = try awaitFailure(from: sut.execute(poll: .fixture(), optionId: "si"))
        XCTAssertEqual(error as? RefereePollVoteError, .notSignedIn)
        XCTAssertEqual(repository.voteCallCount, 0)
    }

    func test_execute_withUnknownOption_failsWithoutHittingRepository() throws {
        signIn()
        let error = try awaitFailure(from: sut.execute(poll: .fixture(), optionId: "nope"))
        XCTAssertEqual(error as? RefereePollVoteError, .unknownOption)
        XCTAssertEqual(repository.voteCallCount, 0)
    }

    func test_execute_whenPollClosed_failsWithoutHittingRepository() throws {
        signIn()
        let closed = RefereePoll.fixture(cierraEn: Date().addingTimeInterval(-10))
        let error = try awaitFailure(from: sut.execute(poll: closed, optionId: "si"))
        XCTAssertEqual(error as? RefereePollVoteError, .pollClosed)
        XCTAssertEqual(repository.voteCallCount, 0)
    }

    func test_execute_happyPath_votesAndReturnsOption() throws {
        signIn()
        let poll = RefereePoll.fixture(numShards: 7)

        let voted = try awaitValue(from: sut.execute(poll: poll, optionId: " si "))

        XCTAssertEqual(voted, "si")
        XCTAssertEqual(repository.voteCallCount, 1)
        XCTAssertEqual(repository.lastVote?.pollId, poll.id)
        XCTAssertEqual(repository.lastVote?.optionId, "si")
        XCTAssertEqual(repository.lastVote?.uid, "user-123")
        XCTAssertEqual(repository.lastVote?.numShards, 7)
    }

    func test_execute_propagatesRepositoryFailure() throws {
        signIn()
        repository.voteResult = .failure(TestError.network)

        let error = try awaitFailure(from: sut.execute(poll: .fixture(), optionId: "si"))
        XCTAssertEqual(error as? TestError, .network)
    }
}
