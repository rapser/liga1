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

class FavoritosViewModel {

    // MARK: - Published Properties

    @Published private(set) var teams: [TeamUI] = []
    @Published private(set) var allTeams: [TeamUI] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var favoriteTeamIds: Set<String> = []

    // MARK: - Dependencies

    private let fetchTeamsUseCase: FetchTeamsUseCaseProtocol
    private let toggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCaseProtocol
    private let observeFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol
    private let notificationTopicManager: NotificationTopicManagerProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        fetchTeamsUseCase: FetchTeamsUseCaseProtocol,
        toggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCaseProtocol,
        observeFavoriteTeamsUseCase: ObserveFavoriteTeamsUseCaseProtocol,
        notificationTopicManager: NotificationTopicManagerProtocol
    ) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
        self.toggleFavoriteTeamUseCase = toggleFavoriteTeamUseCase
        self.observeFavoriteTeamsUseCase = observeFavoriteTeamsUseCase
        self.notificationTopicManager = notificationTopicManager

        observeFavoriteTeams()
        fetchAllTeams()
    }

    // MARK: - Public Methods - Teams

    func refreshFavoriteTeamsIfNeeded() {
        observeFavoriteTeamsUseCase.refreshFavoriteTeams()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func toggleFavoriteTeam(teamId: String) {
        toggleFavoriteTeamUseCase.execute(teamId: teamId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    // Error silently handled
                }
            } receiveValue: { [weak self] _ in
                self?.notificationTopicManager.syncTopicsWithFavorites()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeFavoriteTeams() {
        observeFavoriteTeamsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteTeamIds in
                self?.favoriteTeamIds = favoriteTeamIds
                self?.updateFavoriteTeams()
            }
            .store(in: &cancellables)
    }

    private func fetchAllTeams() {
        isLoading = true
        error = nil

        fetchTeamsUseCase.execute(for: .apertura)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] teams in
                guard let self = self else { return }
                var teamUIs = TeamUIMapper.toUI(from: teams)
                for index in teamUIs.indices {
                    let teamCode = teamUIs[index].logo.lowercased()
                    teamUIs[index].isFavorite = self.favoriteTeamIds.contains(teamCode)
                }
                self.allTeams = teamUIs
                self.updateFavoriteTeams()
            }
            .store(in: &cancellables)
    }

    private func updateFavoriteTeams() {
        var favoriteTeamsArray: [TeamUI] = []

        for teamId in favoriteTeamIds {
            if let team = allTeams.first(where: { $0.logo.lowercased() == teamId.lowercased() }) {
                var updatedTeam = team
                updatedTeam.isFavorite = true
                favoriteTeamsArray.append(updatedTeam)
            }
        }

        self.teams = favoriteTeamsArray

        if !favoriteTeamIds.isEmpty && favoriteTeamsArray.isEmpty && allTeams.isEmpty {
            fetchAllTeams()
        }
    }
}
