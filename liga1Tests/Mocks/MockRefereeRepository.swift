import Combine
@testable import liga1

final class MockRefereeRepository: RefereeRepositoryProtocol {

    var fetchResult: Result<RefereeProfile?, Error> = .success(nil)
    private(set) var fetchCallCount = 0
    private(set) var lastRefereeId: String?

    func fetchReferee(id refereeId: String) -> AnyPublisher<RefereeProfile?, Error> {
        fetchCallCount += 1
        lastRefereeId = refereeId
        switch fetchResult {
        case .success(let value):
            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
