//
//  HomeViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import Combine

class HomeViewModel {

    // MARK: - Published Properties

    @Published private(set) var jornadaSections: [JornadaSection] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var favoriteMatchIds: Set<String> = []

    // MARK: - Dependencies

    private let fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol
    private let observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol
    private let fetchMatchesUseCase: FetchMatchesUseCaseProtocol
    private let observeMatchesUseCase: ObserveMatchesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var matchCancellables: [String: AnyCancellable] = [:]
    private var activeJornadas: [Jornada] = []
    private var jornadaMatches: [String: [Match]] = [:]

    // MARK: - Initialization

    init(
        fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol,
        observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol,
        fetchMatchesUseCase: FetchMatchesUseCaseProtocol,
        observeMatchesUseCase: ObserveMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    ) {
        self.fetchActiveJornadasUseCase = fetchActiveJornadasUseCase
        self.observeActiveJornadasUseCase = observeActiveJornadasUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.observeMatchesUseCase = observeMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase

        observeActiveJornadas()
        observeFavorites()
    }

    // MARK: - Public Methods

    func fetchActiveJornadas() {
        isLoading = true
        error = nil

        fetchActiveJornadasUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch active jornadas", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] jornadas in
                self?.loadMatchesForJornadas(jornadas)
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(matchId: String) {
        toggleFavoriteUseCase.execute(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("HomeViewModel: Failed to toggle favorite for match: \(matchId)", error: error)
                }
            } receiveValue: { _ in
                // Favorite toggled successfully
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeActiveJornadas() {
        observeActiveJornadasUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] jornadas in
                self?.loadMatchesForJornadas(jornadas)
            }
            .store(in: &cancellables)
    }

    private func observeFavorites() {
        observeFavoritesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                self?.favoriteMatchIds = favoriteIds
                self?.updateMatchesFavoriteStatus()
            }
            .store(in: &cancellables)
    }

    private func loadMatchesForJornadas(_ jornadas: [Jornada]) {
        guard !jornadas.isEmpty else {
            Logger.shared.warning("HomeViewModel: No jornadas to load matches for")
            jornadaSections = []
            // Cancelar todos los listeners de matches cuando no hay jornadas
            matchCancellables.values.forEach { $0.cancel() }
            matchCancellables.removeAll()
            activeJornadas = []
            jornadaMatches.removeAll()
            return
        }

        Logger.shared.debug("HomeViewModel: Observing matches for \(jornadas.count) jornadas")
        
        // Guardar jornadas activas
        activeJornadas = jornadas
        
        // Obtener IDs de jornadas activas
        let activeJornadaIds = Set(jornadas.map { $0.id })
        
        // Cancelar listeners de jornadas que ya no están activas
        let jornadaIdsToRemove = matchCancellables.keys.filter { !activeJornadaIds.contains($0) }
        for jornadaId in jornadaIdsToRemove {
            Logger.shared.debug("HomeViewModel: Canceling observer for jornada: \(jornadaId)")
            matchCancellables[jornadaId]?.cancel()
            matchCancellables.removeValue(forKey: jornadaId)
            jornadaMatches.removeValue(forKey: jornadaId)
        }
        
        // Observar matches para cada jornada activa
        for jornada in jornadas {
            // Si ya existe un cancellable para esta jornada, saltarla (ya está observando)
            if matchCancellables[jornada.id] != nil {
                Logger.shared.debug("HomeViewModel: Already observing jornada: \(jornada.id)")
                continue
            }
            
            Logger.shared.debug("HomeViewModel: Starting to observe matches for jornada: \(jornada.id)")
            
            let cancellable = observeMatchesUseCase.execute(for: jornada.id)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] matches in
                    guard let self = self else { return }
                    Logger.shared.debug("HomeViewModel: Received \(matches.count) matches for jornada \(jornada.id)")
                    self.jornadaMatches[jornada.id] = matches
                    self.updateJornadaSections()
                }
            
            matchCancellables[jornada.id] = cancellable
        }
        
        // Procesar inmediatamente si ya tenemos datos para todas las jornadas
        updateJornadaSections()
    }
    
    private func updateJornadaSections() {
        // Procesar solo si tenemos datos para todas las jornadas activas
        guard !activeJornadas.isEmpty else { return }
        
        let hasAllData = activeJornadas.allSatisfy { jornadaMatches[$0.id] != nil }
        guard hasAllData else {
            Logger.shared.debug("HomeViewModel: Waiting for all jornadas data")
            return
        }
        
        let results = activeJornadas.compactMap { jornada -> (Jornada, [Match])? in
            guard let matches = jornadaMatches[jornada.id] else { return nil }
            return (jornada, matches)
        }
        
        processJornadasWithMatches(results)
    }

    private func processJornadasWithMatches(_ results: [(Jornada, [Match])]) {
        Logger.shared.debug("HomeViewModel: Processing \(results.count) jornada results")
        var tempSections: [JornadaSection] = []

        for (jornada, matches) in results {
            Logger.shared.debug("HomeViewModel: Processing jornada \(jornada.id) with \(matches.count) matches")
            
            // Convertir Match a MatchUI usando el mapper
            // Primero convertir sin favoriteIds, luego actualizar en updateMatchesFavoriteStatus
            let matchUIs = MatchUIMapper.toUI(from: matches)
            Logger.shared.debug("HomeViewModel: Converted \(matchUIs.count) matches to MatchUI for jornada \(jornada.id)")

            let section = JornadaSection(
                jornadaId: jornada.id,
                numero: jornada.numero,
                torneo: jornada.torneo,
                matches: matchUIs
            )
            tempSections.append(section)
        }

        // Ordenar secciones por número de jornada descendente
        jornadaSections = tempSections.sorted { $0.numero > $1.numero }
        Logger.shared.info("HomeViewModel: Created \(jornadaSections.count) sections with total \(jornadaSections.reduce(0) { $0 + $1.matches.count }) matches")
        
        // Actualizar el estado de favoritos después de crear las secciones
        updateMatchesFavoriteStatus()
    }

    private func updateMatchesFavoriteStatus() {
        // Actualizar el estado de favoritos en cada sección
        for (index, section) in jornadaSections.enumerated() {
            var updatedMatches = section.matches
            for (matchIndex, matchUI) in updatedMatches.enumerated() {
                // El ID completo incluye la jornada
                let fullMatchId = "\(section.jornadaId)_\(matchUI.id)"
                let isFav = favoriteMatchIds.contains(fullMatchId)
                updatedMatches[matchIndex].isFavorite = isFav
            }
            jornadaSections[index].matches = updatedMatches
        }
    }

    // MARK: - Nested Types

    struct JornadaSection {
        let jornadaId: String
        let numero: Int
        let torneo: String
        var matches: [MatchUI]
    }
}
