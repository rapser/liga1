//
//  NotificationTopicManager.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import Combine

protocol NotificationTopicManagerProtocol {
    func startObserving()
    func stopObserving()
    func syncTopicsWithFavorites()
    func unsubscribeFromAllTeamTopics()
    func resubscribeToSavedTopics()
}

/// Sincroniza equipos favoritos y preferencias con suscripciones FCM.
class NotificationTopicManager: NotificationTopicManagerProtocol {

    // MARK: - Dependencies

    private let notificationService: NotificationServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let userPreferencesService: UserPreferencesServiceProtocol

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let liga1AllTopic = "liga1_all"

    // MARK: - Initialization

    init(
        notificationService: NotificationServiceProtocol,
        favoritesService: FavoritesServiceProtocol,
        userPreferencesService: UserPreferencesServiceProtocol
    ) {
        self.notificationService = notificationService
        self.favoritesService = favoritesService
        self.userPreferencesService = userPreferencesService
    }

    // MARK: - NotificationTopicManagerProtocol

    func startObserving() {
        favoritesService.observeFavoriteTeams()
            .removeDuplicates()
            .combineLatest(userPreferencesService.observePreferences())
            .sink { [weak self] favoriteTeamIds, preferences in
                guard let self = self else { return }

                guard let preferences = preferences,
                      preferences.pushNotificationsEnabled else {
                    return
                }

                self.syncTopics(
                    favoriteTeamIds: favoriteTeamIds,
                    currentTopics: preferences.subscribedTopics
                )
            }
            .store(in: &cancellables)
    }

    func stopObserving() {
        cancellables.removeAll()
    }

    func syncTopicsWithFavorites() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }

            let favoriteTeamIds = self.favoritesService.getCurrentFavoriteTeams()

            self.userPreferencesService.observePreferences()
                .first()
                .sink { [weak self] preferences in
                    guard let self = self else { return }

                    let currentTopics = preferences?.subscribedTopics ?? []
                    let isEnabled = preferences?.pushNotificationsEnabled ?? true

                    if isEnabled {
                        self.syncTopics(favoriteTeamIds: favoriteTeamIds, currentTopics: currentTopics)
                    }
                }
                .store(in: &self.cancellables)
        }
    }

    func unsubscribeFromAllTeamTopics() {
        userPreferencesService.getUserPreferences()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("Error obteniendo preferencias", error: error)
                    }
                },
                receiveValue: { [weak self] preferences in
                    guard let self = self,
                          let preferences = preferences else {
                        return
                    }

                    let teamTopics = preferences.subscribedTopics.filter { $0.starts(with: "team_") }

                    teamTopics.forEach { topic in
                        self.notificationService.unsubscribeFromTopic(topic)
                    }
                }
            )
            .store(in: &cancellables)
    }

    func resubscribeToSavedTopics() {
        userPreferencesService.getUserPreferences()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("Error obteniendo preferencias", error: error)
                    }
                },
                receiveValue: { [weak self] preferences in
                    guard let self = self,
                          let preferences = preferences else {
                        return
                    }

                    preferences.subscribedTopics.forEach { topic in
                        self.notificationService.subscribeToTopic(topic)
                    }
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    /// Sincroniza los topics FCM con los favoritos actuales
    private func syncTopics(favoriteTeamIds: Set<String>, currentTopics: Set<String>) {
        let desiredTopics = Set(favoriteTeamIds.map { topicName(for: $0) })

        let toSubscribe = desiredTopics.subtracting(currentTopics)
        let toUnsubscribe = currentTopics
            .subtracting(desiredTopics)
            .filter { $0.starts(with: "team_") }

        if !toSubscribe.isEmpty || !toUnsubscribe.isEmpty {
            applyTopicChanges(subscribe: toSubscribe, unsubscribe: toUnsubscribe)
        }
    }

    /// Aplica cambios de suscripción/desuscripción a topics
    private func applyTopicChanges(subscribe: Set<String>, unsubscribe: Set<String>) {
        unsubscribe.forEach { topic in
            notificationService.unsubscribeFromTopic(topic)
            removeTopicFromPreferences(topic)
        }

        subscribe.forEach { topic in
            notificationService.subscribeToTopic(topic)
            addTopicToPreferences(topic)
        }
    }

    /// Agrega un topic a las preferencias de usuario en Firestore
    private func addTopicToPreferences(_ topic: String) {
        userPreferencesService.addSubscribedTopic(topic)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("Error agregando topic a preferencias", error: error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    /// Remueve un topic de las preferencias de usuario en Firestore
    private func removeTopicFromPreferences(_ topic: String) {
        userPreferencesService.removeSubscribedTopic(topic)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("Error removiendo topic de preferencias", error: error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    /// Crea el topic name de FCM usando el código del equipo
    private func topicName(for teamId: String) -> String {
        let normalizedTeamId = teamId.lowercased()
        return "team_\(normalizedTeamId)"
    }
}
