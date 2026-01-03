//
//  TorneoViewModel.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine

class TorneoViewModel {

    // MARK: - Published Properties

    @Published private(set) var displayedTeams: [Team] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var selectedTorneo: TorneoType = .clausura

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var cachedApertura: [Team] = []
    private var cachedClausura: [Team] = []
    private var cachedAcumulado: [Team] = []

    // MARK: - Initialization

    init(fetchTeamsUseCase: FetchTeamsUseCaseProtocol) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
    }

    // MARK: - Public Methods

    func loadTeams(for torneo: TorneoType) {
        selectedTorneo = torneo

        switch torneo {
        case .apertura:
            if !cachedApertura.isEmpty {
                displayedTeams = cachedApertura
            } else {
                fetchTeams(for: torneo)
            }

        case .clausura:
            if !cachedClausura.isEmpty {
                displayedTeams = cachedClausura
            } else {
                fetchTeams(for: torneo)
            }

        case .acumulado:
            if !cachedAcumulado.isEmpty {
                displayedTeams = cachedAcumulado
            } else {
                fetchAcumulado()
            }
        }
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
                    Logger.shared.error("Failed to fetch teams for torneo: \(torneo)", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] teams in
                guard let self = self else { return }
                Logger.shared.info("Fetched \(teams.count) teams for \(torneo)")
                self.displayedTeams = teams

                switch torneo {
                case .apertura:
                    self.cachedApertura = teams
                case .clausura:
                    self.cachedClausura = teams
                case .acumulado:
                    break
                }
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
                    Logger.shared.error("Failed to fetch acumulado teams", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] (aperturaTeams, clausuraTeams) in
                guard let self = self else { return }
                Logger.shared.info("Calculating acumulado from \(aperturaTeams.count) apertura and \(clausuraTeams.count) clausura teams")

                var teamsDict: [String: Team] = [:]

                for team in aperturaTeams {
                    teamsDict[team.nombre] = team
                }

                for team in clausuraTeams {
                    if let existing = teamsDict[team.nombre] {
                        let combined = Team(
                            nombre: existing.nombre,
                            ciudad: existing.ciudad,
                            estadio: existing.estadio,
                            logo: existing.logo,
                            partidosJugados: existing.partidosJugados + team.partidosJugados,
                            partidosGanados: existing.partidosGanados + team.partidosGanados,
                            partidosEmpatados: existing.partidosEmpatados + team.partidosEmpatados,
                            partidosPerdidos: existing.partidosPerdidos + team.partidosPerdidos,
                            golesFavor: existing.golesFavor + team.golesFavor,
                            golesContra: existing.golesContra + team.golesContra,
                            diferenciaGoles: existing.diferenciaGoles + team.diferenciaGoles,
                            puntos: existing.puntos + team.puntos
                        )
                        teamsDict[team.nombre] = combined
                    } else {
                        teamsDict[team.nombre] = team
                    }
                }

                let acumuladoTeams = Array(teamsDict.values).sorted {
                    if $0.puntos == $1.puntos {
                        return $0.diferenciaGoles > $1.diferenciaGoles
                    }
                    return $0.puntos > $1.puntos
                }

                self.cachedAcumulado = acumuladoTeams
                self.displayedTeams = acumuladoTeams
            }
            .store(in: &cancellables)
    }
}
