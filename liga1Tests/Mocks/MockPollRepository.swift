import Combine
@testable import liga1

final class MockPollRepository: PollRepositoryProtocol {

    let activePollSubject = CurrentValueSubject<RefereePoll?, Error>(nil)
    let tallySubject = CurrentValueSubject<[String: Int], Error>([:])
    var myVoteResult: Result<String?, Error> = .success(nil)
    var voteResult: Result<Void, Error> = .success(())

    private(set) var observeActivePollCallCount = 0
    private(set) var lastMatchId: String?
    private(set) var voteCallCount = 0
    private(set) var lastVote: (pollId: String, optionId: String, uid: String, numShards: Int)?

    func observeActivePoll(matchId: String) -> AnyPublisher<RefereePoll?, Error> {
        observeActivePollCallCount += 1
        lastMatchId = matchId
        return activePollSubject.eraseToAnyPublisher()
    }

    func observeTally(pollId: String) -> AnyPublisher<[String: Int], Error> {
        tallySubject.eraseToAnyPublisher()
    }

    func fetchMyVote(pollId: String, uid: String) -> AnyPublisher<String?, Error> {
        myVoteResult.publisher.eraseToAnyPublisher()
    }

    func vote(pollId: String, optionId: String, uid: String, numShards: Int) -> AnyPublisher<Void, Error> {
        voteCallCount += 1
        lastVote = (pollId, optionId, uid, numShards)
        return voteResult.publisher.eraseToAnyPublisher()
    }
}
