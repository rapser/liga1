// GetJornadaToDisplayUseCaseTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class GetJornadaToDisplayUseCaseTests: XCTestCase {

    private var fetchUseCase: MockFetchActiveJornadasUseCase!
    private var observeUseCase: MockObserveActiveJornadasUseCase!
    private var sut: GetJornadaToDisplayUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        fetchUseCase = MockFetchActiveJornadasUseCase()
        observeUseCase = MockObserveActiveJornadasUseCase()
        sut = GetJornadaToDisplayUseCase(
            fetchActiveJornadasUseCase: fetchUseCase,
            observeActiveJornadasUseCase: observeUseCase
        )
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        fetchUseCase = nil
        observeUseCase = nil
        super.tearDown()
    }

    // MARK: - orderJornadasForHome (pure function)

    func test_order_sortsByTorneoThenNumeroThenId() {
        let j1 = Jornada.fixture(id: "a", torneo: "apertura", numero: 2)
        let j2 = Jornada.fixture(id: "b", torneo: "apertura", numero: 1)
        let j3 = Jornada.fixture(id: "c", torneo: "clausura", numero: 1)

        let sorted = GetJornadaToDisplayUseCase.orderJornadasForHome([j3, j1, j2])

        XCTAssertEqual(sorted[0].id, "b") // apertura-1
        XCTAssertEqual(sorted[1].id, "a") // apertura-2
        XCTAssertEqual(sorted[2].id, "c") // clausura-1
    }

    func test_order_sameTorneoAndNumero_sortById() {
        let j1 = Jornada.fixture(id: "z", torneo: "apertura", numero: 1)
        let j2 = Jornada.fixture(id: "a", torneo: "apertura", numero: 1)

        let sorted = GetJornadaToDisplayUseCase.orderJornadasForHome([j1, j2])

        XCTAssertEqual(sorted[0].id, "a")
        XCTAssertEqual(sorted[1].id, "z")
    }

    func test_order_emptyInput_returnsEmpty() {
        let sorted = GetJornadaToDisplayUseCase.orderJornadasForHome([])
        XCTAssertTrue(sorted.isEmpty)
    }

    // MARK: - execute()

    func test_execute_delegatesToFetchUseCase() throws {
        let jornadas = [Jornada.fixture(id: "j1"), Jornada.fixture(id: "j2")]
        fetchUseCase.result = .success(jornadas)

        let result = try awaitValue(from: sut.execute())

        XCTAssertEqual(fetchUseCase.executeCallCount, 1)
        XCTAssertEqual(result.map(\.id), jornadas.map(\.id))
    }

    func test_execute_returnsSortedJornadas() throws {
        let unsorted = [
            Jornada.fixture(id: "c", torneo: "clausura", numero: 1),
            Jornada.fixture(id: "b", torneo: "apertura", numero: 2),
            Jornada.fixture(id: "a", torneo: "apertura", numero: 1)
        ]
        fetchUseCase.result = .success(unsorted)

        let result = try awaitValue(from: sut.execute())

        XCTAssertEqual(result.map(\.id), ["a", "b", "c"])
    }

    func test_execute_propagatesError() {
        fetchUseCase.result = .failure(TestError.network)

        var failed = false
        let exp = expectation(description: "error")
        sut.execute().sink(
            receiveCompletion: { if case .failure = $0 { failed = true; exp.fulfill() } },
            receiveValue: { _ in }
        ).store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertTrue(failed)
    }

    // MARK: - observe()

    func test_observe_forwardsSortedJornadasFromSubject() {
        let unsorted = [
            Jornada.fixture(id: "b", torneo: "apertura", numero: 2),
            Jornada.fixture(id: "a", torneo: "apertura", numero: 1)
        ]
        var received: [Jornada] = []
        let exp = expectation(description: "value")
        exp.expectedFulfillmentCount = 2

        sut.observe()
            .sink { received = $0; exp.fulfill() }
            .store(in: &cancellables)

        observeUseCase.sendJornadas(unsorted)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(received.map(\.id), ["a", "b"])
    }
}

// MARK: - Local Mocks

private final class MockFetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol {
    var result: Result<[Jornada], Error> = .success([])
    var executeCallCount = 0
    func execute() -> AnyPublisher<[Jornada], Error> {
        executeCallCount += 1
        switch result {
        case .success(let v): return Just(v).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let e): return Fail(error: e).eraseToAnyPublisher()
        }
    }
}

private final class MockObserveActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol {
    private let subject = CurrentValueSubject<[Jornada], Never>([])
    func execute() -> AnyPublisher<[Jornada], Never> { subject.eraseToAnyPublisher() }
    func sendJornadas(_ jornadas: [Jornada]) { subject.send(jornadas) }
}
