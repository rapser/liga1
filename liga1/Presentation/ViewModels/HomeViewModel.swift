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
    private let fetchMatchesUseCase: FetchMatchesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol,
        fetchMatchesUseCase: FetchMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    ) {
        self.fetchActiveJornadasUseCase = fetchActiveJornadasUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase

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
            return
        }

        Logger.shared.debug("HomeViewModel: Loading matches for \(jornadas.count) jornadas")
        
        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            Logger.shared.debug("HomeViewModel: Creating publisher for jornada: \(jornada.id)")
            return fetchMatchesUseCase.execute(for: jornada.id)
                .map { matches in
                    Logger.shared.debug("HomeViewModel: Received \(matches.count) matches for jornada \(jornada.id)")
                    return (jornada, matches)
                }
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("HomeViewModel: Failed to load matches for jornadas", error: error)
                    self?.error = error
                } else {
                    Logger.shared.debug("HomeViewModel: Successfully loaded all matches")
                }
            } receiveValue: { [weak self] results in
                Logger.shared.info("HomeViewModel: Processing \(results.count) jornada results")
                self?.processJornadasWithMatches(results)
            }
            .store(in: &cancellables)
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
