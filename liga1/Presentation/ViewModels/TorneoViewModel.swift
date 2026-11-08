//
//  TorneoViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine

class TorneoViewModel {

    // MARK: - Published Properties

    @Published private(set) var displayedTeams: [TeamUI] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var selectedTorneo: TorneoType
    @Published private(set) var availableTorneos: [TorneoType]
    /// Sanciones de puntos que explican la tabla acumulada (vacío en Apertura/Clausura).
    @Published private(set) var sanctionNotes: [SanctionNoteUI] = []

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol
    private let tournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    /// Suscripción al listener de la tabla visible; se reemplaza al cambiar de torneo.
    private var standingsSubscription: AnyCancellable?
    private var observedTorneo: TorneoType?

    // MARK: - Initialization

    init(
        fetchTeamsUseCase: FetchTeamsUseCaseProtocol,
        tournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol
    ) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
        self.tournamentAvailabilityUseCase = tournamentAvailabilityUseCase
        let clausuraEnabled = tournamentAvailabilityUseCase.activeClausuraEnabled
        self.selectedTorneo = clausuraEnabled ? .clausura : .apertura
        self.availableTorneos = clausuraEnabled
            ? [.apertura, .clausura, .acumulado]
            : [.apertura]
    }

    // MARK: - Public Methods

    func start() {
        loadTeams(for: selectedTorneo)
        refreshTournamentAvailability()
    }

    func refreshTournamentAvailability() {
        tournamentAvailabilityUseCase.refreshClausuraEnabled()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                let updatedTorneos: [TorneoType] = isEnabled
                    ? [.apertura, .clausura, .acumulado]
                    : [.apertura]

                // Evita reconstruir el selector si Remote Config confirmó el
                // mismo valor con el que la pantalla ya inició localmente.
                guard updatedTorneos != self.availableTorneos else { return }
                self.availableTorneos = updatedTorneos

                if isEnabled {
                    self.loadTeams(for: .clausura)
                } else if !self.availableTorneos.contains(self.selectedTorneo) {
                    self.loadTeams(for: .apertura)
                }
            }
            .store(in: &cancellables)
    }

    /// Muestra la tabla del torneo y la mantiene viva con el listener de Firestore:
    /// sale al instante desde la caché persistente y se actualiza sola cuando el
    /// admin registra un resultado. Llamarla otra vez con el mismo torneo no hace nada.
    func loadTeams(for torneo: TorneoType) {
        guard availableTorneos.contains(torneo) else { return }
        selectedTorneo = torneo
        observeStandings(for: torneo)
    }

    // MARK: - Private Methods

    private func observeStandings(for torneo: TorneoType) {
        guard observedTorneo != torneo || standingsSubscription == nil else { return }
        observedTorneo = torneo
        isLoading = true
        error = nil
        if torneo != .acumulado { sanctionNotes = [] }

        // El Acumulado ya viene con las sanciones descontadas (lo mantiene el admin);
        // las sanciones solo se escuchan para la leyenda y el asterisco.
        let standings: AnyPublisher<([Team], [PointSanction]), Never> = torneo == .acumulado
            ? fetchTeamsUseCase.observe(for: .acumulado)
                .combineLatest(fetchTeamsUseCase.observePointSanctions())
                .eraseToAnyPublisher()
            : fetchTeamsUseCase.observe(for: torneo)
                .map { ($0, []) }
                .eraseToAnyPublisher()

        standingsSubscription = standings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] teams, sanctions in
                guard let self = self else { return }
                self.isLoading = false
                self.sanctionNotes = SanctionNoteUI.make(from: sanctions, teams: teams)
                let sanctionedCodes = Set(self.sanctionNotes.map(\.teamCode))
                self.displayedTeams = TeamUIMapper.toUI(from: teams).map { team in
                    var team = team
                    team.hasPointSanction = sanctionedCodes.contains(team.logo)
                    return team
                }
            }
    }
}
