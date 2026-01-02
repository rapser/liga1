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

    private let jornadasRepository: JornadasRepositoryProtocol
    private let matchesRepository: MatchesRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        jornadasRepository: JornadasRepositoryProtocol = JornadasRepository(),
        matchesRepository: MatchesRepositoryProtocol = MatchesRepository(),
        favoritesService: FavoritesServiceProtocol = FavoritesService()
    ) {
        self.jornadasRepository = jornadasRepository
        self.matchesRepository = matchesRepository
        self.favoritesService = favoritesService

        observeFavorites()
    }

    // MARK: - Public Methods

    func fetchActiveJornadas() {
        isLoading = true
        error = nil

        jornadasRepository.fetchActiveJornadas()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] jornadas in
                self?.loadMatchesForJornadas(jornadas)
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(matchId: String) {
        favoritesService.toggleFavorite(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(_) = completion {
                    // Handle error silently or log if needed
                }
            } receiveValue: { _ in
                // Favorite toggled successfully
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeFavorites() {
        favoritesService.observeFavorites()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                self?.favoriteMatchIds = favoriteIds
                self?.updateMatchesFavoriteStatus()
            }
            .store(in: &cancellables)
    }

    private func loadMatchesForJornadas(_ jornadas: [Jornada]) {
        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            guard let jornadaId = jornada.id else {
                return Fail(error: NSError(domain: "HomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Jornada sin ID"]))
                    .eraseToAnyPublisher()
            }

            return matchesRepository.fetchMatches(for: jornadaId)
                .map { matches in (jornada, matches) }
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
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
            guard let jornadaId = jornada.id,
                  let numero = jornada.numero,
                  let torneo = jornada.torneo else { continue }

            let section = JornadaSection(
                jornadaId: jornadaId,
                numero: numero,
                torneo: torneo,
                matches: matches
            )
            tempSections.append(section)
        }

        // Ordenar secciones por número de jornada descendente
        jornadaSections = tempSections.sorted { $0.numero > $1.numero }
    }

    private func updateMatchesFavoriteStatus() {
        // Actualizar el estado de favoritos en cada sección
        for (index, section) in jornadaSections.enumerated() {
            var updatedMatches = section.matches
            for (matchIndex, match) in updatedMatches.enumerated() {
                if let matchId = match.id {
                    updatedMatches[matchIndex].isFavorite = favoriteMatchIds.contains(matchId)
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
        var matches: [Match]
    }
}
