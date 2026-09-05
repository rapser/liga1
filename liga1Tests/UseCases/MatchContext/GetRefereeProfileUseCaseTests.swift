import XCTest
@testable import liga1

final class GetRefereeProfileUseCaseTests: XCTestCase {

    private var repository: MockRefereeRepository!
    private var sut: GetRefereeProfileUseCase!

    override func setUp() {
        super.setUp()
        repository = MockRefereeRepository()
        sut = GetRefereeProfileUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_slugsNameBeforeQueryingRepository() throws {
        let referee = RefereeProfile(id: "kevin-ortega", fullName: "Kevin Ortega")
        repository.fetchResult = .success(referee)

        let result = try awaitValue(from: sut.execute(refereeName: "  Kevin Ortega  "))

        XCTAssertEqual(result, referee)
        XCTAssertEqual(repository.lastRefereeId, "kevin-ortega")
    }

    func test_execute_stripsDiacriticsInSlug() throws {
        repository.fetchResult = .success(nil)

        _ = try awaitValue(from: sut.execute(refereeName: "Jesús Cartagena"))

        XCTAssertEqual(repository.lastRefereeId, "jesus-cartagena")
    }

    func test_execute_withBlankName_returnsNilWithoutHittingRepository() throws {
        let result = try awaitValue(from: sut.execute(refereeName: " -- "))

        XCTAssertNil(result)
        XCTAssertEqual(repository.fetchCallCount, 0)
    }
}
