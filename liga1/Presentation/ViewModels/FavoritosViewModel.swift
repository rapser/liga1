//
//  FavoritosViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//  Refactored on 03/01/26.
//  Updated on 17/01/26 - Added teams support
//

import Foundation
import Combine

enum FavoritesSegment: Int {
    case matches = 0
    case teams = 1
}

class FavoritosViewModel {

    // MARK: - Published Properties

    @Published private(set) var matches: [MatchUI] = []
    @Published private(set) var teams: [TeamUI] = []
    @Published private(set) var allTeams: [TeamUI] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var favoriteMatchIds: Set<String> = []
    @Published private(set) var favoriteTeamIds: Set<String> = []
    @Published var selectedSegment: FavoritesSegment = .matches

    // MARK: - Dependencies

    private let fetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol
    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol
    private let toggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCaseProtocol
    private let observeFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchFavoriteMatchesUseCase: FetchFavoriteMatchesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        observeFavoritesUseCase: ObserveFavoritesUseCaseProtocol,
        fetchTeamsUseCase: FetchTeamsUseCaseProtocol,
        toggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCaseProtocol,
        observeFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol
    ) {
        self.fetchFavoriteMatchesUseCase = fetchFavoriteMatchesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.observeFavoritesUseCase = observeFavoritesUseCase
        self.fetchTeamsUseCase = fetchTeamsUseCase
        self.toggleFavoriteTeamUseCase = toggleFavoriteTeamUseCase
        self.observeFavoriteTeamsUseCase = observeFavoriteTeamsUseCase

        observeFavorites()
        observeFavoriteTeams()
        fetchAllTeams()
    }

    // MARK: - Public Methods - Matches

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

    // MARK: - Public Methods - Teams

    func toggleFavoriteTeam(teamId: String) {
        toggleFavoriteTeamUseCase.execute(teamId: teamId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to toggle favorite for team: \(teamId)", error: error)
                }
            } receiveValue: { _ in
                // Favorite team toggled successfully
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

    private func observeFavoriteTeams() {
        observeFavoriteTeamsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteTeamIds in
                self?.favoriteTeamIds = favoriteTeamIds
                self?.updateFavoriteTeams()
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
                var matchUIs = MatchUIMapper.toUI(from: matches)
                for index in matchUIs.indices {
                    let fullMatchId = matchUIs[index].id
                    matchUIs[index].isFavorite = self.favoriteMatchIds.contains(fullMatchId)
                }
                self.matches = matchUIs
            }
            .store(in: &cancellables)
    }

    private func fetchAllTeams() {
        isLoading = true
        error = nil

        // Fetch teams for Apertura tournament (we can use either Apertura or Clausura)
        fetchTeamsUseCase.execute(for: .apertura)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch teams", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] teams in
                guard let self = self else { return }
                var teamUIs = TeamUIMapper.toUI(from: teams)
                for index in teamUIs.indices {
                    teamUIs[index].isFavorite = self.favoriteTeamIds.contains(teamUIs[index].nombre)
                }
                self.allTeams = teamUIs
                self.updateFavoriteTeams()
            }
            .store(in: &cancellables)
    }

    private func updateFavoriteTeams() {
        var favoriteTeamsArray: [TeamUI] = []

        for teamId in favoriteTeamIds {
            if let team = allTeams.first(where: { $0.nombre == teamId }) {
                var updatedTeam = team
                updatedTeam.isFavorite = true
                favoriteTeamsArray.append(updatedTeam)
            }
        }

        self.teams = favoriteTeamsArray
    }
}
