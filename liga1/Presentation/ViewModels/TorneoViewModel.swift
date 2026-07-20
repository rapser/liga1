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

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol
    private let tournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol
    private let calculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchTeamsUseCase: FetchTeamsUseCaseProtocol,
        tournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol,
        calculateAccumulatedStandingsUseCase: CalculateAccumulatedStandingsUseCaseProtocol
    ) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
        self.tournamentAvailabilityUseCase = tournamentAvailabilityUseCase
        self.calculateAccumulatedStandingsUseCase = calculateAccumulatedStandingsUseCase
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

    func loadTeams(for torneo: TorneoType) {
        guard availableTorneos.contains(torneo) else { return }
        selectedTorneo = torneo
        if torneo == .acumulado {
            fetchAcumulado()
        } else {
            fetchTeams(for: torneo)
        }
    }

    /// Fuerza recarga ignorando la caché en memoria
    func reloadTeams(for torneo: TorneoType) {
        guard availableTorneos.contains(torneo) else { return }
        selectedTorneo = torneo
        if torneo == .acumulado {
            fetchTeamsUseCase.invalidateCache(for: nil)
        } else {
            fetchTeamsUseCase.invalidateCache(for: torneo)
        }
        loadTeams(for: torneo)
    }

    // MARK: - Private Methods

    private func fetchTeams(for torneo: TorneoType) {
        isLoading = true
        error = nil

        fetchTeamsUseCase.execute(for: torneo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] teams in
                self?.displayedTeams = TeamUIMapper.toUI(from: teams)
            }
            .store(in: &cancellables)
    }

    private func fetchAcumulado() {
        isLoading = true
        error = nil

        Publishers.Zip(
            fetchTeamsUseCase.execute(for: .apertura),
            fetchTeamsUseCase.execute(for: .clausura)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] aperturaTeams, clausuraTeams in
            guard let self = self else { return }
            let merged = self.calculateAccumulatedStandingsUseCase.execute(
                apertura: aperturaTeams,
                clausura: clausuraTeams
            )
            self.displayedTeams = TeamUIMapper.toUI(from: merged)
        }
        .store(in: &cancellables)
    }
}
