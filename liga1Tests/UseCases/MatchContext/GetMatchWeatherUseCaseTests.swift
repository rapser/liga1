import XCTest
@testable import liga1

final class GetMatchWeatherUseCaseTests: XCTestCase {

    private var repository: MockWeatherRepository!
    private var sut: GetMatchWeatherUseCase!

    override func setUp() {
        super.setUp()
        repository = MockWeatherRepository()
        sut = GetMatchWeatherUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    private func makeWeather() -> MatchWeather {
        MatchWeather(
            temperatureC: 18.4, feelsLikeC: 17.1, humidityPct: 72, windKmh: 14,
            precipitationProbPct: 20, wmoCode: 3, condition: .nubes,
            symbol: "cloud.fill", referenceHour: "2026-09-05T18:00"
        )
    }

    func test_execute_delegatesTrimmedIdsToRepository() throws {
        let weather = makeWeather()
        repository.fetchResult = .success(weather)

        let result = try awaitValue(from: sut.execute(jornadaId: "  clausura_05 ", matchId: " hua_ali "))

        XCTAssertEqual(result, weather)
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(repository.lastJornadaId, "clausura_05")
        XCTAssertEqual(repository.lastMatchId, "hua_ali")
    }

    func test_execute_withEmptyJornada_returnsNilWithoutHittingRepository() throws {
        let result = try awaitValue(from: sut.execute(jornadaId: "   ", matchId: "hua_ali"))

        XCTAssertNil(result)
        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    func test_execute_withEmptyMatch_returnsNilWithoutHittingRepository() throws {
        let result = try awaitValue(from: sut.execute(jornadaId: "clausura_05", matchId: ""))

        XCTAssertNil(result)
        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    func test_execute_propagatesRepositoryFailure() throws {
        repository.fetchResult = .failure(TestError.generic)

        let error = try awaitFailure(from: sut.execute(jornadaId: "clausura_05", matchId: "hua_ali"))

        XCTAssertEqual(error as? TestError, .generic)
    }
}
