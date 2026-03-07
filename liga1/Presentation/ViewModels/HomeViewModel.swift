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

    private let getJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol
    private let fetchMatchesUseCase: FetchMatchesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        getJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol,
        fetchMatchesUseCase: FetchMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    ) {
        self.getJornadaToDisplayUseCase = getJornadaToDisplayUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase

        observeJornadaToDisplay()
        observeFavorites()
    }

    // MARK: - Public Methods

    func fetchActiveJornadas() {
        isLoading = true
        error = nil

        getJornadaToDisplayUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] jornada in
                self?.loadMatchesForJornadas(jornada.map { [$0] } ?? [])
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(matchId: String) {
        toggleFavoriteUseCase.execute(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    // Error silently handled
                }
            } receiveValue: { _ in
                // Favorite toggled successfully
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeJornadaToDisplay() {
        getJornadaToDisplayUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] jornada in
                self?.loadMatchesForJornadas(jornada.map { [$0] } ?? [])
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

        // Ordenar secciones por número de jornada ascendente (fecha más próxima primero)
        jornadaSections = tempSections.sorted { $0.numero < $1.numero }
        
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
}
