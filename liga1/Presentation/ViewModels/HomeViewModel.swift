//
//  HomeViewModel.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
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

        Logger.shared.debug("Fetching active jornadas")

        fetchActiveJornadasUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch active jornadas", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] jornadas in
                Logger.shared.info("Successfully fetched \(jornadas.count) active jornadas")
                self?.loadMatchesForJornadas(jornadas)
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(matchId: String) {
        Logger.shared.debug("HomeViewModel: Toggling favorite for matchId: \(matchId)")

        toggleFavoriteUseCase.execute(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("HomeViewModel: Failed to toggle favorite for match: \(matchId)", error: error)
                }
            } receiveValue: { _ in
                Logger.shared.debug("HomeViewModel: Favorite toggled successfully for match: \(matchId)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeFavorites() {
        observeFavoritesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                Logger.shared.debug("HomeViewModel: Observed favorites updated, count: \(favoriteIds.count)")
                Logger.shared.debug("HomeViewModel: Favorite IDs: \(favoriteIds)")
                self?.favoriteMatchIds = favoriteIds
                self?.updateMatchesFavoriteStatus()
            }
            .store(in: &cancellables)
    }

    private func loadMatchesForJornadas(_ jornadas: [Jornada]) {
        Logger.shared.debug("Loading matches for \(jornadas.count) jornadas")

        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            guard let jornadaId = jornada.id else {
                return Fail(error: NSError(domain: "HomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Jornada sin ID"]))
                    .eraseToAnyPublisher()
            }

            return fetchMatchesUseCase.execute(for: jornadaId)
                .map { matches in (jornada, matches) }
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to load matches for jornadas", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] results in
                Logger.shared.info("Successfully loaded matches for all jornadas")
                self?.processJornadasWithMatches(results)
            }
            .store(in: &cancellables)
    }

    private func processJornadasWithMatches(_ results: [(Jornada, [Match])]) {
        var tempSections: [JornadaSection] = []

        for (jornada, matches) in results {
            guard let jornadaId = jornada.id,
                  let numero = jornada.numero,
                  let torneo = jornada.torneo else { continue }

            // Convertir Match a MatchPresentationModel
            let presentationMatches = matches.map { match in
                MatchPresentationModel(
                    match: match,
                    isFavorite: false, // Se actualizará con updateMatchesFavoriteStatus()
                    jornadaNumero: numero,
                    torneoNombre: torneo
                )
            }

            let section = JornadaSection(
                jornadaId: jornadaId,
                numero: numero,
                torneo: torneo,
                matches: presentationMatches
            )
            tempSections.append(section)
        }

        // Ordenar secciones por número de jornada descendente
        jornadaSections = tempSections.sorted { $0.numero > $1.numero }
    }

    private func updateMatchesFavoriteStatus() {
        Logger.shared.debug("HomeViewModel: Updating matches favorite status")

        // Actualizar el estado de favoritos en cada sección
        for (index, section) in jornadaSections.enumerated() {
            var updatedMatches = section.matches
            for (matchIndex, presentationMatch) in updatedMatches.enumerated() {
                if let matchId = presentationMatch.id {
                    // El ID completo incluye la jornada
                    let fullMatchId = "\(section.jornadaId)_\(matchId)"
                    let isFav = favoriteMatchIds.contains(fullMatchId)
                    updatedMatches[matchIndex].isFavorite = isFav
                    Logger.shared.debug("HomeViewModel: Match \(fullMatchId) isFavorite: \(isFav)")
                }
            }
            jornadaSections[index].matches = updatedMatches
        }
    }

    // MARK: - Nested Types

    struct JornadaSection {
        let jornadaId: String
        let numero: Int
        let torneo: String
        var matches: [MatchPresentationModel]
    }
}
