// CachingTeamsRepositoryTests.swift
// liga1Tests

import XCTest
import Combine
@testable import liga1

final class CachingTeamsRepositoryTests: XCTestCase {

    private var inner: MockTeamsRepository!
    private var sut: CachingTeamsRepository!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        inner = MockTeamsRepository()
        sut = CachingTeamsRepository(wrapping: inner)
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        inner = nil
        super.tearDown()
    }

    // MARK: - Cache Miss (primera llamada)

    func test_fetchTeams_firstCall_delegatesToInner() throws {
        inner.fetchResult = .success([Team.fixture()])
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))
        XCTAssertEqual(inner.fetchCallCount, 1)
    }

    // MARK: - Cache Hit (segunda llamada)

    func test_fetchTeams_secondCall_doesNotCallInner() throws {
        inner.fetchResult = .success([Team.fixture()])
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))  // populate cache
        inner.fetchCallCount = 0                                    // reset counter

        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))  // should hit cache

        XCTAssertEqual(inner.fetchCallCount, 0, "La segunda llamada debería resolver desde caché")
    }

    func test_fetchTeams_cacheHit_returnsCorrectTeams() throws {
        let expected = [Team.fixture(nombre: "Alianza"), Team.fixture(nombre: "Universitario")]
        inner.fetchResult = .success(expected)

        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))
        let cached = try awaitValue(from: sut.fetchTeams(for: .apertura))

        XCTAssertEqual(cached, expected)
    }

    // MARK: - Torneo isolation

    func test_fetchTeams_differentTorneos_cachedSeparately() throws {
        let aperturaTeams = [Team.fixture(nombre: "AperturaTeam")]
        let clausuraTeams = [Team.fixture(nombre: "ClausuraTeam")]

        inner.fetchResult = .success(aperturaTeams)
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))

        inner.fetchResult = .success(clausuraTeams)
        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))

        inner.fetchCallCount = 0

        // Both hits should come from cache
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))
        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))

        XCTAssertEqual(inner.fetchCallCount, 0)
    }

    // MARK: - invalidateCache (torneo específico)

    func test_invalidateCache_specificTorneo_refetchesFromInner() throws {
        inner.fetchResult = .success([Team.fixture()])
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))

        sut.invalidateCache(for: .apertura)
        inner.fetchCallCount = 0

        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))

        XCTAssertEqual(inner.fetchCallCount, 1, "Tras invalidar debería buscar en el inner repository")
    }

    func test_invalidateCache_specificTorneo_doesNotAffectOtherTorneo() throws {
        let clausuraTeams = [Team.fixture(nombre: "ClausuraTeam")]
        inner.fetchResult = .success(clausuraTeams)
        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))

        sut.invalidateCache(for: .apertura)   // invalida solo apertura
        inner.fetchCallCount = 0

        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))  // debe venir de caché

        XCTAssertEqual(inner.fetchCallCount, 0, "Clausura no debería verse afectada al invalidar apertura")
    }

    // MARK: - invalidateCache (all)

    func test_invalidateCache_nil_invalidatesAll() throws {
        inner.fetchResult = .success([Team.fixture()])
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))
        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))

        sut.invalidateCache(for: nil)
        inner.fetchCallCount = 0

        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))
        _ = try awaitValue(from: sut.fetchTeams(for: .clausura))

        XCTAssertEqual(inner.fetchCallCount, 2)
    }

    // MARK: - Error propagation

    func test_fetchTeams_innerError_propagatesError() {
        inner.fetchResult = .failure(TestError.network)
        let error = try? awaitFailure(from: sut.fetchTeams(for: .apertura))
        XCTAssertNotNil(error)
    }

    func test_fetchTeams_innerError_doesNotPopulateCache() throws {
        inner.fetchResult = .failure(TestError.network)
        _ = try? awaitFailure(from: sut.fetchTeams(for: .apertura))

        inner.fetchResult = .success([Team.fixture()])
        inner.fetchCallCount = 0
        _ = try awaitValue(from: sut.fetchTeams(for: .apertura))

        XCTAssertEqual(inner.fetchCallCount, 1, "Un error previo no debe dejar datos en caché")
    }
}
