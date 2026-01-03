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

    @Published private(set) var matches: [Match] = []
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
        fetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol = DIContainer.shared.makeFetchFavoriteMatchesUseCase(),
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol = DIContainer.shared.makeToggleFavoriteUseCase(),
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol = DIContainer.shared.makeObserveFavoritesUseCase()
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
                Logger.shared.debug("Favorite toggled successfully for match: \(matchId)")
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

        Logger.shared.debug("Fetching \(favoriteMatchIds.count) favorite matches")

        fetchFavoriteMatchesUseCase.execute(favoriteMatchIds: favoriteMatchIds)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch favorite matches", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] matches in
                Logger.shared.info("Successfully fetched \(matches.count) favorite matches")
                self?.matches = matches
            }
            .store(in: &cancellables)
    }
}
