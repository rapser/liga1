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

/// Servicio orquestador que sincroniza equipos favoritos con suscripciones FCM
/// Responsabilidades:
/// 1. Observar cambios en favoritos de equipos
/// 2. Observar cambios en preferencias de notificaciones
/// 3. Sincronizar suscripciones a topics FCM automáticamente
/// 4. Mantener persistencia de topics en Firestore
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
        Logger.shared.info("🎯 NotificationTopicManager: Iniciando observación")

        // Observar cambios en favoritos de equipos + preferencias de usuario
        favoritesService.observeFavoriteTeams()
            .combineLatest(userPreferencesService.observePreferences())
            .sink { [weak self] favoriteTeamIds, preferences in
                guard let self = self else { return }

                Logger.shared.debug("🔄 Cambio detectado - Favoritos: \(favoriteTeamIds.count), Preferencias: \(preferences != nil)")

                // Si preferencias no existen o notificaciones están desactivadas, no sincronizar
                guard let preferences = preferences,
                      preferences.pushNotificationsEnabled else {
                    Logger.shared.info("🔕 Notificaciones desactivadas - No sincronizando topics")
                    return
                }

                // Sincronizar topics con favoritos actuales
                self.syncTopics(
                    favoriteTeamIds: favoriteTeamIds,
                    currentTopics: preferences.subscribedTopics
                )
            }
            .store(in: &cancellables)

        Logger.shared.info("✅ NotificationTopicManager: Observación activa")
    }

    func stopObserving() {
        Logger.shared.info("⏹️ NotificationTopicManager: Deteniendo observación")
        cancellables.removeAll()
    }

    func syncTopicsWithFavorites() {
        Logger.shared.info("📋 Sincronizando topics con favoritos...")

        // Obtener favoritos y preferencias actuales de forma síncrona
        var favoriteTeamIds: Set<String> = []
        var preferences: UserPreferences?

        favoritesService.observeFavoriteTeams()
            .first()
            .sink { ids in
                favoriteTeamIds = ids
            }
            .store(in: &cancellables)

        userPreferencesService.observePreferences()
            .first()
            .sink { prefs in
                preferences = prefs
            }
            .store(in: &cancellables)

        // Esperar un breve momento para que los valores se obtengan
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            // Si no hay preferencias, crear con valores por defecto
            let currentTopics = preferences?.subscribedTopics ?? []
            let isEnabled = preferences?.pushNotificationsEnabled ?? true

            if isEnabled {
                self.syncTopics(favoriteTeamIds: favoriteTeamIds, currentTopics: currentTopics)
            } else {
                Logger.shared.info("🔕 Notificaciones desactivadas - Saltando sincronización")
            }
        }
    }

    func unsubscribeFromAllTeamTopics() {
        Logger.shared.info("🔕 Desuscribiendo de todos los topics de equipos...")

        userPreferencesService.getUserPreferences()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("❌ Error obteniendo preferencias", error: error)
                    }
                },
                receiveValue: { [weak self] preferences in
                    guard let self = self,
                          let preferences = preferences else {
                        return
                    }

                    // Filtrar solo topics de equipos (no remover liga1_all)
                    let teamTopics = preferences.subscribedTopics.filter { $0.starts(with: "team_") }

                    Logger.shared.info("🔕 Desuscribiendo de \(teamTopics.count) topics de equipos")

                    // Desuscribirse de cada topic de equipo
                    teamTopics.forEach { topic in
                        self.notificationService.unsubscribeFromTopic(topic)
                    }
                }
            )
            .store(in: &cancellables)
    }

    func resubscribeToSavedTopics() {
        Logger.shared.info("🔄 Re-suscribiendo a topics guardados...")

        userPreferencesService.getUserPreferences()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("❌ Error obteniendo preferencias", error: error)
                    }
                },
                receiveValue: { [weak self] preferences in
                    guard let self = self,
                          let preferences = preferences else {
                        return
                    }

                    Logger.shared.info("🔄 Re-suscribiendo a \(preferences.subscribedTopics.count) topics")

                    // Re-suscribirse a todos los topics guardados
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
        // Convertir favoritos a topics (normalizar nombres)
        let desiredTopics = Set(favoriteTeamIds.map { topicName(for: $0) })

        // Calcular diferencias
        let toSubscribe = desiredTopics.subtracting(currentTopics)
        let toUnsubscribe = currentTopics
            .subtracting(desiredTopics)
            .filter { $0.starts(with: "team_") } // No remover liga1_all

        Logger.shared.debug("📊 Sincronización - Subscribe: \(toSubscribe.count), Unsubscribe: \(toUnsubscribe.count)")

        // Aplicar cambios si hay diferencias
        if !toSubscribe.isEmpty || !toUnsubscribe.isEmpty {
            applyTopicChanges(subscribe: toSubscribe, unsubscribe: toUnsubscribe)
        } else {
            Logger.shared.debug("✅ Topics ya sincronizados - Sin cambios necesarios")
        }
    }

    /// Aplica cambios de suscripción/desuscripción a topics
    private func applyTopicChanges(subscribe: Set<String>, unsubscribe: Set<String>) {
        // Desuscribirse de topics que ya no son favoritos
        unsubscribe.forEach { topic in
            notificationService.unsubscribeFromTopic(topic)
            removeTopicFromPreferences(topic)
        }

        // Suscribirse a nuevos topics
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
                        Logger.shared.error("❌ Error agregando topic a preferencias", error: error)
                    }
                },
                receiveValue: {
                    Logger.shared.debug("💾 Topic agregado a preferencias: \(topic)")
                }
            )
            .store(in: &cancellables)
    }

    /// Remueve un topic de las preferencias de usuario en Firestore
    private func removeTopicFromPreferences(_ topic: String) {
        userPreferencesService.removeSubscribedTopic(topic)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("❌ Error removiendo topic de preferencias", error: error)
                    }
                },
                receiveValue: {
                    Logger.shared.debug("🗑️ Topic removido de preferencias: \(topic)")
                }
            )
            .store(in: &cancellables)
    }

    /// Crea el topic name de FCM usando el código del equipo
    /// El teamId ya viene en formato corto (ej: "ali", "uni", "cri")
    /// Solo se necesita agregar el prefijo "team_"
    private func topicName(for teamId: String) -> String {
        return "team_\(teamId)"
    }
}
