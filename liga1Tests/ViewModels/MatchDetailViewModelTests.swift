import XCTest
import Combine
@testable import liga1

final class MatchDetailViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(
        arbitro: String? = "Kevin Ortega",
        stadium: Stadium? = nil,
        referee: RefereeProfile? = nil,
        weather: MatchWeather? = nil,
        pollSubject: CurrentValueSubject<RefereePoll?, Error> = .init(nil),
        tallySubject: CurrentValueSubject<[String: Int], Error> = .init([:]),
        myVote: String? = nil,
        submitVote: SubmitRefereePollVoteUseCaseProtocol? = nil
    ) -> MatchDetailViewModel {
        let match = MatchUI(id: "hua_ali", equipoLocalId: "hua", equipoVisitanteId: "ali",
                            fecha: Date(timeIntervalSince1970: 1_770_000_000), arbitro: arbitro)
        let context = MatchDetailContext(jornadaId: "clausura_05", jornadaNumero: 5, torneo: "clausura", match: match)
        return MatchDetailViewModel(
            context: context,
            getStadiumUseCase: StubStadiumUseCase(result: stadium),
            getRefereeProfileUseCase: StubRefereeUseCase(result: referee),
            getMatchWeatherUseCase: StubWeatherUseCase(result: weather),
            observeRefereePollUseCase: StubObservePollUseCase(subject: pollSubject),
            observePollResultUseCase: StubPollResultUseCase(subject: tallySubject, myVote: myVote),
            submitRefereePollVoteUseCase: submitVote ?? StubSubmitVoteUseCase(result: .success("si"))
        )
    }

    private func makeWeather(
        temp: Double = 18.4,
        feelsLike: Double = 17.1,
        condition: MatchWeather.Condition = .nubes,
        precipProb: Int = 20
    ) -> MatchWeather {
        MatchWeather(
            temperatureC: temp, feelsLikeC: feelsLike, humidityPct: 72, windKmh: 14,
            precipitationProbPct: precipProb, wmoCode: 3, condition: condition,
            symbol: "cloud.fill", referenceHour: "2026-09-05T18:00"
        )
    }

    // MARK: - load()

    func test_load_populatesStadiumAndReferee() {
        let stadium = Stadium(code: "estadio-huancayo", name: "Estadio Huancayo",
                              city: "Huancayo", altitudeMsnm: 3271, capacity: 20000)
        let referee = RefereeProfile(id: "kevin-ortega", fullName: "Kevin Ortega", nationality: "PER")
        let sut = makeSUT(stadium: stadium, referee: referee)

        let exp = expectation(description: "stadium + referee")
        exp.expectedFulfillmentCount = 2
        sut.$stadium.dropFirst().sink { if $0 != nil { exp.fulfill() } }.store(in: &cancellables)
        sut.$referee.dropFirst().sink { if $0 != nil { exp.fulfill() } }.store(in: &cancellables)

        sut.load()
        wait(for: [exp], timeout: 2)

        XCTAssertEqual(sut.stadium, stadium)
        XCTAssertEqual(sut.referee, referee)
    }

    func test_load_withNoArbitro_doesNotFetchReferee() {
        let sut = makeSUT(arbitro: nil, referee: RefereeProfile(id: "x", fullName: "X"))
        sut.load()
        // sin árbitro no se dispara el fetch → referee sigue nil
        XCTAssertNil(sut.referee)
    }

    // MARK: - Display: Sabor Local

    func test_altitudDisplay_hasGroupingAndMsnmSuffix() throws {
        let sut = makeSUT(stadium: Stadium(code: "c", name: "E", altitudeMsnm: 3271))
        loadAndSettle(sut)
        let display = try XCTUnwrap(sut.altitudDisplay)
        // El separador de miles depende del locale es_PE del entorno; no lo fijamos.
        XCTAssertTrue(display.hasSuffix(" msnm"), display)
        XCTAssertTrue(display.contains("3"), display)
        XCTAssertTrue(display.contains("271"), display)
        XCTAssertGreaterThan(display.count, "3271 msnm".count) // hubo agrupación
        XCTAssertTrue(sut.saborLocalDisponible)
    }

    func test_factorGeografico_byAltitudeBand() {
        XCTAssertEqual(factor(for: 3300), "Altura extrema")
        XCTAssertEqual(factor(for: 2320), "Factor altura")
        XCTAssertEqual(factor(for: 800), "Media altura")
        XCTAssertEqual(factor(for: 60), "Nivel del mar")
    }

    func test_esDeAltura_thresholdAt2000() {
        XCTAssertFalse(makeLoadedSUT(altitude: 1999).esDeAltura)
        XCTAssertTrue(makeLoadedSUT(altitude: 2000).esDeAltura)
    }

    func test_saborLocalDisponible_falseWhenNoStadium() {
        let sut = makeSUT(stadium: nil)
        loadAndSettle(sut)
        XCTAssertFalse(sut.saborLocalDisponible)
        XCTAssertNil(sut.altitudDisplay)
    }

    // MARK: - Display: Termómetro Arbitral

    func test_refereeStats_nilWhenNoCareer() {
        let sut = makeSUT(referee: RefereeProfile(id: "k", fullName: "Kevin Ortega"))
        loadAndSettle(sut)
        XCTAssertNil(sut.refereePenalesPorPartidoDisplay)
        XCTAssertNil(sut.refereeTarjetasPorPartidoDisplay)
        XCTAssertEqual(sut.refereeNombreDisplay, "Kevin Ortega")
    }

    func test_refereeStats_formattedWhenCareerPresent() {
        let career = RefereeProfile.Career(matches: 120, penaltiesPerGame: 0.283, yellowPerGame: 4.6, redPerGame: 0.22)
        let sut = makeSUT(referee: RefereeProfile(id: "k", fullName: "Kevin Ortega", career: career))
        loadAndSettle(sut)
        XCTAssertEqual(sut.refereePenalesPorPartidoDisplay, "0.28")
        XCTAssertEqual(sut.refereeTarjetasPorPartidoDisplay, "4.6 amarillas · 0.22 rojas")
    }

    func test_refereeNombreDisplay_fallsBackToRawArbitro() {
        let sut = makeSUT(arbitro: "Bruno Pérez", referee: nil)
        loadAndSettle(sut)
        XCTAssertEqual(sut.refereeNombreDisplay, "Bruno Pérez")
    }

    // MARK: - Display: Sabor Local (clima)

    func test_load_populatesWeather() {
        let sut = makeSUT(weather: makeWeather())
        loadAndSettle(sut)
        XCTAssertTrue(sut.climaDisponible)
        XCTAssertEqual(sut.climaResumenDisplay, "Nublado · 18°")
        XCTAssertEqual(sut.climaIconoSF, "cloud.fill")
    }

    func test_clima_noDisponible_whenNil() {
        let sut = makeSUT(weather: nil)
        loadAndSettle(sut)
        XCTAssertFalse(sut.climaDisponible)
        XCTAssertNil(sut.climaResumenDisplay)
        XCTAssertNil(sut.climaVientoDisplay)
    }

    func test_climaSensacion_shownOnlyWhenItDiffers() {
        let iguales = makeSUT(weather: makeWeather(temp: 18.2, feelsLike: 18.0))
        loadAndSettle(iguales)
        XCTAssertNil(iguales.climaSensacionDisplay)

        let distintas = makeSUT(weather: makeWeather(temp: 18.4, feelsLike: 14.9))
        loadAndSettle(distintas)
        XCTAssertEqual(distintas.climaSensacionDisplay, "15°C")
    }

    func test_climaPrecipitacion_hiddenBelowTenPercent() {
        let bajo = makeSUT(weather: makeWeather(precipProb: 5))
        loadAndSettle(bajo)
        XCTAssertNil(bajo.climaPrecipitacionDisplay)

        let alto = makeSUT(weather: makeWeather(precipProb: 60))
        loadAndSettle(alto)
        XCTAssertEqual(alto.climaPrecipitacionDisplay, "60%")
    }

    func test_saborLocalSection_appearsWithWeatherEvenWithoutStadium() {
        let sut = makeSUT(stadium: nil, weather: makeWeather())
        loadAndSettle(sut)
        XCTAssertFalse(sut.saborLocalDisponible)
        XCTAssertTrue(sut.climaDisponible)
    }

    // MARK: - Termómetro Arbitral

    func test_pollNotAvailable_whenNoActivePoll() {
        let sut = makeSUT()
        loadAndSettle(sut)
        XCTAssertFalse(sut.refereePollDisponible)
        XCTAssertTrue(sut.refereePollOpciones.isEmpty)
    }

    func test_activePoll_populatesOptionsWithTallyAndPercent() {
        let pollSubject = CurrentValueSubject<RefereePoll?, Error>(RefereePoll.fixture())
        let tallySubject = CurrentValueSubject<[String: Int], Error>(["si": 3, "no": 1, "dudoso": 0])
        let sut = makeSUT(pollSubject: pollSubject, tallySubject: tallySubject)
        loadAndSettle(sut)

        XCTAssertTrue(sut.refereePollDisponible)
        XCTAssertTrue(sut.refereePollAbierta)
        let si = sut.refereePollOpciones.first { $0.id == "si" }
        XCTAssertEqual(si?.votos, 3)
        XCTAssertEqual(si?.porcentaje, 75)
        XCTAssertEqual(sut.refereePollTotalDisplay, "4 votos")
        XCTAssertTrue(sut.puedeVotarRefereePoll)
    }

    func test_seededVote_marksYaVoteAndBlocksVoting() {
        let pollSubject = CurrentValueSubject<RefereePoll?, Error>(RefereePoll.fixture())
        let sut = makeSUT(pollSubject: pollSubject, myVote: "no")
        loadAndSettle(sut)

        XCTAssertTrue(sut.refereePollYaVote)
        XCTAssertFalse(sut.puedeVotarRefereePoll)
        XCTAssertEqual(sut.refereePollOpciones.first { $0.esMiVoto }?.id, "no")
    }

    func test_voteRefereePoll_setsMyVoteOnSuccess() {
        let pollSubject = CurrentValueSubject<RefereePoll?, Error>(RefereePoll.fixture())
        let sut = makeSUT(
            pollSubject: pollSubject,
            submitVote: StubSubmitVoteUseCase(result: .success("dudoso"))
        )
        loadAndSettle(sut)

        sut.voteRefereePoll(optionId: "dudoso")
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        XCTAssertEqual(sut.myPollVote, "dudoso")
        XCTAssertFalse(sut.pollVoteInFlight)
        XCTAssertNil(sut.pollVoteError)
    }

    func test_voteRefereePoll_setsErrorOnFailure() {
        let pollSubject = CurrentValueSubject<RefereePoll?, Error>(RefereePoll.fixture())
        let sut = makeSUT(
            pollSubject: pollSubject,
            submitVote: StubSubmitVoteUseCase(result: .failure(RefereePollVoteError.pollClosed))
        )
        loadAndSettle(sut)

        sut.voteRefereePoll(optionId: "si")
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        XCTAssertNil(sut.myPollVote)
        XCTAssertEqual(sut.pollVoteError, RefereePollVoteError.pollClosed.errorDescription)
    }

    func test_closedPoll_isNotVotable_butStillShown() {
        let closed = RefereePoll.fixture(cierraEn: Date().addingTimeInterval(-5))
        let pollSubject = CurrentValueSubject<RefereePoll?, Error>(closed)
        let sut = makeSUT(pollSubject: pollSubject)
        loadAndSettle(sut)

        XCTAssertTrue(sut.refereePollDisponible)
        XCTAssertFalse(sut.refereePollAbierta)
        XCTAssertFalse(sut.puedeVotarRefereePoll)
        XCTAssertEqual(sut.refereePollEstadoDisplay, "Cerrada")
    }

    // MARK: - Private

    /// `load()` publica en la cola main; se bombea el run loop para que los
    /// valores síncronos de los stubs lleguen antes de las aserciones.
    private func loadAndSettle(_ sut: MatchDetailViewModel) {
        sut.load()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
    }

    private func factor(for altitude: Int) -> String? {
        makeLoadedSUT(altitude: altitude).factorGeograficoDisplay
    }

    private func makeLoadedSUT(altitude: Int) -> MatchDetailViewModel {
        let sut = makeSUT(stadium: Stadium(code: "c", name: "E", altitudeMsnm: altitude))
        loadAndSettle(sut)
        return sut
    }
}

// MARK: - Stubs

private struct StubStadiumUseCase: GetStadiumForTeamUseCaseProtocol {
    let result: Stadium?
    func execute(homeTeamCode: String) -> AnyPublisher<Stadium?, Error> {
        Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private struct StubRefereeUseCase: GetRefereeProfileUseCaseProtocol {
    let result: RefereeProfile?
    func execute(refereeName: String) -> AnyPublisher<RefereeProfile?, Error> {
        Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private struct StubWeatherUseCase: GetMatchWeatherUseCaseProtocol {
    let result: MatchWeather?
    func execute(jornadaId: String, matchId: String) -> AnyPublisher<MatchWeather?, Error> {
        Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private struct StubObservePollUseCase: ObserveRefereePollUseCaseProtocol {
    let subject: CurrentValueSubject<RefereePoll?, Error>
    func execute(matchId: String) -> AnyPublisher<RefereePoll?, Error> {
        subject.eraseToAnyPublisher()
    }
}

private struct StubPollResultUseCase: ObservePollResultUseCaseProtocol {
    let subject: CurrentValueSubject<[String: Int], Error>
    let myVote: String?
    func execute(pollId: String) -> AnyPublisher<PollResult, Error> {
        subject.map { PollResult(tally: $0, myVote: self.myVote) }.eraseToAnyPublisher()
    }
}

private struct StubSubmitVoteUseCase: SubmitRefereePollVoteUseCaseProtocol {
    let result: Result<String, Error>
    func execute(poll: RefereePoll, optionId: String) -> AnyPublisher<String, Error> {
        result.publisher.eraseToAnyPublisher()
    }
}
