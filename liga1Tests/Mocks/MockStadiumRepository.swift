import Combine
@testable import liga1

final class MockStadiumRepository: StadiumRepositoryProtocol {

    var fetchResult: Result<Stadium?, Error> = .success(nil)
    private(set) var fetchCallCount = 0
    private(set) var lastTeamCode: String?

    func fetchStadium(forHomeTeam teamCode: String) -> AnyPublisher<Stadium?, Error> {
        fetchCallCount += 1
        lastTeamCode = teamCode
        switch fetchResult {
        case .success(let value):
            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
