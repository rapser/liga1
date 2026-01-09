//
//  FavoritosViewModel.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine

class FavoritosViewModel {

    // MARK: - Published Properties

    @Published private(set) var matches: [MatchUI] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var favoriteMatchIds: Set<String> = []

    // MARK: - Dependencies

    private let fetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    ) {
        self.fetchFavoriteMatchesUseCase = fetchFavoriteMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase

        observeFavorites()
    }

    // MARK: - Public Methods

    func toggleFavorite(matchId: String) {
        toggleFavoriteUseCase.execute(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to toggle favorite for match: \(matchId)", error: error)
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
                self?.fetchFavoriteMatches()
            }
            .store(in: &cancellables)
    }

    private func fetchFavoriteMatches() {
        guard !favoriteMatchIds.isEmpty else {
            self.matches = []
            return
        }

        isLoading = true
        error = nil

        fetchFavoriteMatchesUseCase.execute(favoriteMatchIds: favoriteMatchIds)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch favorite matches", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] matches in
                guard let self = self else { return }
                // Convertir Match a MatchUI usando el mapper
                var matchUIs = MatchUIMapper.toUI(from: matches)
                // Actualizar el estado de favorito basado en favoriteMatchIds
                for index in matchUIs.indices {
                    let fullMatchId = matchUIs[index].id
                    matchUIs[index].isFavorite = self.favoriteMatchIds.contains(fullMatchId)
                }
                self.matches = matchUIs
            }
            .store(in: &cancellables)
    }
}
