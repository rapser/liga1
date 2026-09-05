//
//  StandingsSimulatorViewModel.swift
//  liga1
//
//  Simulador interactivo de tabla / descenso. Patrón Action → State:
//  la vista envía `Action`s por `send(_:)`, el VM recalcula y publica `State`.
//  El recálculo es síncrono (motor puro) — mover un marcador reordena la tabla al instante.
//

import Foundation
import Combine

final class StandingsSimulatorViewModel {

    // MARK: - State

    struct Fixture: Equatable {
        let id: String
        let jornadaId: String
        let jornadaNumero: Int
        let homeCode: String
        let awayCode: String
        let homeName: String
        let awayName: String
        var homeGoals: Int
        var awayGoals: Int
    }

    struct ProjectedRow: Equatable {
        let pos: Int
        let code: String
        let name: String
        let pj: Int
        let pts: Int
        let dg: Int
        let zone: QualificationZone
        /// Movimiento respecto a la tabla actual: >0 sube, <0 baja, 0 igual.
        let deltaVsBase: Int
    }

    struct State {
        var torneo: TorneoType = .clausura
        var isLoading = false
        var error: String?
        var fixtures: [Fixture] = []
        var projected: [ProjectedRow] = []
    }

    enum Action {
        case load(TorneoType)
        case setScore(id: String, home: Int, away: Int)
        case resetScores
    }

    @Published private(set) var state = State()

    /// Marcadores restantes agrupados por jornada (para la UI).
    var groupedFixtures: [(jornada: Int, fixtures: [Fixture])] {
        Dictionary(grouping: state.fixtures, by: \.jornadaNumero)
            .map { (jornada: $0.key, fixtures: $0.value) }
            .sorted { $0.jornada < $1.jornada }
    }

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol
    private let calculateAccumulatedUseCase: CalculateAccumulatedStandingsUseCaseProtocol
    private let fetchRemainingFixturesUseCase: FetchRemainingFixturesUseCaseProtocol
    private let simulateStandingsUseCase: SimulateStandingsUseCaseProtocol
    private let projectQualificationUseCase: ProjectQualificationUseCaseProtocol

    private var baseTable: [Team] = []
    private var loadCancellable: AnyCancellable?

    init(
        fetchTeamsUseCase: FetchTeamsUseCaseProtocol,
        calculateAccumulatedUseCase: CalculateAccumulatedStandingsUseCaseProtocol,
        fetchRemainingFixturesUseCase: FetchRemainingFixturesUseCaseProtocol,
        simulateStandingsUseCase: SimulateStandingsUseCaseProtocol,
        projectQualificationUseCase: ProjectQualificationUseCaseProtocol
    ) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
        self.calculateAccumulatedUseCase = calculateAccumulatedUseCase
        self.fetchRemainingFixturesUseCase = fetchRemainingFixturesUseCase
        self.simulateStandingsUseCase = simulateStandingsUseCase
        self.projectQualificationUseCase = projectQualificationUseCase
    }

    // MARK: - Action

    func send(_ action: Action) {
        switch action {
        case .load(let torneo):
            load(torneo)

        case .setScore(let id, let home, let away):
            guard let idx = state.fixtures.firstIndex(where: { $0.id == id }) else { return }
            state.fixtures[idx].homeGoals = clampGoals(home)
            state.fixtures[idx].awayGoals = clampGoals(away)
            recompute()

        case .resetScores:
            for i in state.fixtures.indices {
                state.fixtures[i].homeGoals = 0
                state.fixtures[i].awayGoals = 0
            }
            recompute()
        }
    }

    // MARK: - Private

    private func clampGoals(_ value: Int) -> Int { min(20, max(0, value)) }

    private func load(_ torneo: TorneoType) {
        loadCancellable?.cancel()
        state.torneo = torneo
        state.isLoading = true
        state.error = nil
        state.fixtures = []
        state.projected = []

        loadCancellable = Publishers.Zip(
            baseTablePublisher(for: torneo),
            fetchRemainingFixturesUseCase.execute(torneo: torneo)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.state.isLoading = false
                if case .failure(let error) = completion {
                    self.state.error = error.localizedDescription
                }
            },
            receiveValue: { [weak self] base, fixtures in
                guard let self else { return }
                self.baseTable = base
                let nameByCode = Dictionary(base.map { ($0.logo, $0.nombre) }, uniquingKeysWith: { a, _ in a })
                self.state.fixtures = fixtures.map { f in
                    Fixture(
                        id: f.id, jornadaId: f.jornadaId, jornadaNumero: f.jornadaNumero,
                        homeCode: f.homeCode, awayCode: f.awayCode,
                        homeName: nameByCode[f.homeCode] ?? f.homeCode.uppercased(),
                        awayName: nameByCode[f.awayCode] ?? f.awayCode.uppercased(),
                        homeGoals: 0, awayGoals: 0
                    )
                }
                self.state.isLoading = false
                self.recompute()
            }
        )
    }

    private func baseTablePublisher(for torneo: TorneoType) -> AnyPublisher<[Team], Error> {
        switch torneo {
        case .apertura, .clausura:
            return fetchTeamsUseCase.execute(for: torneo)
        case .acumulado:
            return Publishers.Zip(
                fetchTeamsUseCase.execute(for: .apertura),
                fetchTeamsUseCase.execute(for: .clausura)
            )
            .map { [calculateAccumulatedUseCase] apertura, clausura in
                calculateAccumulatedUseCase.execute(apertura: apertura, clausura: clausura)
            }
            .eraseToAnyPublisher()
        }
    }

    private func recompute() {
        let predictions = state.fixtures.map {
            MatchPrediction(
                fixtureId: $0.id, homeCode: $0.homeCode, awayCode: $0.awayCode,
                homeGoals: $0.homeGoals, awayGoals: $0.awayGoals
            )
        }

        let projectedTeams = simulateStandingsUseCase.execute(base: baseTable, predictions: predictions)
        let zones = projectQualificationUseCase.execute(table: projectedTeams, rules: .liga1)

        let basePositions = Dictionary(
            simulateStandingsUseCase.execute(base: baseTable, predictions: [])
                .enumerated().map { ($0.element.logo, $0.offset + 1) },
            uniquingKeysWith: { a, _ in a }
        )

        state.projected = projectedTeams.enumerated().map { index, team in
            let pos = index + 1
            return ProjectedRow(
                pos: pos,
                code: team.logo,
                name: team.nombre,
                pj: team.partidosJugados,
                pts: team.puntos,
                dg: team.diferenciaGoles,
                zone: zones[team.logo] ?? .none,
                deltaVsBase: (basePositions[team.logo] ?? pos) - pos
            )
        }
    }
}
