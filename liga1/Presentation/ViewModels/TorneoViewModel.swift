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
    @Published private(set) var selectedTorneo: TorneoType = .clausura

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(fetchTeamsUseCase: FetchTeamsUseCaseProtocol) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
    }

    // MARK: - Public Methods

    func loadTeams(for torneo: TorneoType) {
        selectedTorneo = torneo
        if torneo == .acumulado {
            fetchAcumulado()
        } else {
            fetchTeams(for: torneo)
        }
    }

    /// Fuerza recarga ignorando la caché en memoria
    func reloadTeams(for torneo: TorneoType) {
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

        let aperturaPublisher = fetchTeamsUseCase.execute(for: .apertura)
        let clausuraPublisher = fetchTeamsUseCase.execute(for: .clausura)

        Publishers.Zip(aperturaPublisher, clausuraPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (aperturaTeams, clausuraTeams) in
                guard let self = self else { return }

                var teamsDict: [String: Team] = [:]
                for team in aperturaTeams { teamsDict[team.nombre] = team }
                for team in clausuraTeams {
                    if let existing = teamsDict[team.nombre] {
                        let gf = existing.golesFavor + team.golesFavor
                        let gc = existing.golesContra + team.golesContra
                        teamsDict[team.nombre] = Team(
                            nombre: existing.nombre,
                            ciudad: existing.ciudad,
                            estadio: existing.estadio,
                            logo: existing.logo,
                            partidosJugados: existing.partidosJugados + team.partidosJugados,
                            partidosGanados: existing.partidosGanados + team.partidosGanados,
                            partidosEmpatados: existing.partidosEmpatados + team.partidosEmpatados,
                            partidosPerdidos: existing.partidosPerdidos + team.partidosPerdidos,
                            golesFavor: gf,
                            golesContra: gc,
                            diferenciaGoles: gf - gc,
                            puntos: existing.puntos + team.puntos
                        )
                    } else {
                        teamsDict[team.nombre] = team
                    }
                }

                let merged = Array(teamsDict.values)
                let sorted: [Team]
                if merged.allSatisfy({ $0.puntos == 0 }) {
                    sorted = merged.sorted { $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending }
                } else {
                    sorted = merged.sorted { Team.isOrderedAboveInStandings($0, $1) }
                }
                self.displayedTeams = TeamUIMapper.toUI(from: sorted)
            }
            .store(in: &cancellables)
    }
}
