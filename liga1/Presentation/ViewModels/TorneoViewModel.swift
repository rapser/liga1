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
    private var cachedApertura: [TeamUI] = []
    private var cachedClausura: [TeamUI] = []
    private var cachedAcumulado: [TeamUI] = []

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
    
    /// Fuerza la recarga de los equipos sin usar caché
    func reloadTeams(for torneo: TorneoType) {
        selectedTorneo = torneo
        
        switch torneo {
        case .apertura:
            cachedApertura = [] // Limpiar caché
            fetchTeams(for: torneo)
        case .clausura:
            cachedClausura = [] // Limpiar caché
            fetchTeams(for: torneo)
        case .acumulado:
            cachedAcumulado = [] // Limpiar caché
            cachedApertura = [] // También limpiar los cachés de apertura y clausura
            cachedClausura = []
            fetchAcumulado()
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
                    self?.error = error
                }
            } receiveValue: { [weak self] teams in
                guard let self = self else { return }
                let teamsUI = TeamUIMapper.toUI(from: teams)
                self.displayedTeams = teamsUI
                switch torneo {
                case .apertura:
                    self.cachedApertura = teamsUI
                case .clausura:
                    self.cachedClausura = teamsUI
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
                    self?.error = error
                }
            } receiveValue: { [weak self] (aperturaTeams, clausuraTeams) in
                guard let self = self else { return }

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

                let acumuladoTeamsArray = Array(teamsDict.values)
                
                // Si todos los equipos tienen 0 puntos, ordenar alfabéticamente
                let allHaveZeroPoints = acumuladoTeamsArray.allSatisfy { $0.puntos == 0 }
                
                let acumuladoTeams: [Team]
                if allHaveZeroPoints {
                    // Ordenar alfabéticamente por nombre
                    acumuladoTeams = acumuladoTeamsArray.sorted {
                        $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending
                    }
                } else {
                    // Ordenar por puntos (descendente) y diferencia de goles (descendente)
                    // Este es el ordenamiento estándar que ya estaba funcionando
                    acumuladoTeams = acumuladoTeamsArray.sorted {
                        if $0.puntos == $1.puntos {
                            return $0.diferenciaGoles > $1.diferenciaGoles
                        }
                        return $0.puntos > $1.puntos
                    }
                }

                let acumuladoTeamsUI = TeamUIMapper.toUI(from: acumuladoTeams)
                self.cachedAcumulado = acumuladoTeamsUI
                self.displayedTeams = acumuladoTeamsUI
            }
            .store(in: &cancellables)
    }
}
