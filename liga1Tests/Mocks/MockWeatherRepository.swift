import Combine
@testable import liga1

final class MockWeatherRepository: WeatherRepositoryProtocol {

    var fetchResult: Result<MatchWeather?, Error> = .success(nil)
    private(set) var fetchCallCount = 0
    private(set) var lastJornadaId: String?
    private(set) var lastMatchId: String?

    func fetchWeather(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error> {
        fetchCallCount += 1
        lastJornadaId = jornadaId
        lastMatchId = matchId
        switch fetchResult {
        case .success(let value):
            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
