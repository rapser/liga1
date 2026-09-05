import XCTest
@testable import liga1

final class GetStadiumForTeamUseCaseTests: XCTestCase {

    private var repository: MockStadiumRepository!
    private var sut: GetStadiumForTeamUseCase!

    override func setUp() {
        super.setUp()
        repository = MockStadiumRepository()
        sut = GetStadiumForTeamUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_delegatesTrimmedCodeToRepository() throws {
        let stadium = Stadium(code: "estadio-huancayo", name: "Estadio Huancayo", altitudeMsnm: 3271)
        repository.fetchResult = .success(stadium)

        let result = try awaitValue(from: sut.execute(homeTeamCode: "  hua "))

        XCTAssertEqual(result, stadium)
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(repository.lastTeamCode, "hua")
    }

    func test_execute_withEmptyCode_returnsNilWithoutHittingRepository() throws {
        let result = try awaitValue(from: sut.execute(homeTeamCode: "   "))

        XCTAssertNil(result)
        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    func test_execute_propagatesRepositoryFailure() throws {
        repository.fetchResult = .failure(TestError.generic)

        let error = try awaitFailure(from: sut.execute(homeTeamCode: "hua"))

        XCTAssertEqual(error as? TestError, .generic)
    }
}
