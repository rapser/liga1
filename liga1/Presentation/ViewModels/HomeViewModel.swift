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
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    private let logger: LoggerProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchActiveJornadasUseCase: FetchActiveJornadasUseCaseProtocol,
        observeActiveJornadasUseCase: ObserveActiveJornadasUseCaseProtocol,
        fetchMatchesUseCase: FetchMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol,
        logger: LoggerProtocol
    ) {
        self.fetchActiveJornadasUseCase = fetchActiveJornadasUseCase
        self.observeActiveJornadasUseCase = observeActiveJornadasUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase
        self.logger = logger

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
                    self?.logger.error("Failed to fetch active jornadas", error: error)
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
                    self.logger.error("HomeViewModel: Failed to toggle favorite for match: \(matchId)", error: error)
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
            jornadaSections = []
            return
        }

        
        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            return fetchMatchesUseCase.execute(for: jornada.id)
                .map { matches in
                    return (jornada, matches)
                }
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.logger.error("HomeViewModel: Failed to load matches for jornadas", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] results in
                self?.processJornadasWithMatches(results)
            }
            .store(in: &cancellables)
    }

    private func processJornadasWithMatches(_ results: [(Jornada, [Match])]) {
        var tempSections: [JornadaSection] = []

        for (jornada, matches) in results {
            
            // Convertir Match a MatchUI usando el mapper
            // Primero convertir sin favoriteIds, luego actualizar en updateMatchesFavoriteStatus
            let matchUIs = MatchUIMapper.toUI(from: matches)

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
