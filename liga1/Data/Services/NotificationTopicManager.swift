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

                Logger.shared.info("🔄 NotificationTopicManager: ========== CAMBIO DETECTADO (Observer Automático) ==========")
                Logger.shared.info("🔄 NotificationTopicManager: Equipos favoritos: \(favoriteTeamIds)")
                Logger.shared.info("🔄 NotificationTopicManager: Preferencias: \(preferences != nil)")

                // Si preferencias no existen o notificaciones están desactivadas, no sincronizar
                guard let preferences = preferences,
                      preferences.pushNotificationsEnabled else {
                    Logger.shared.info("🔕 NotificationTopicManager: Notificaciones desactivadas - No sincronizando topics")
                    Logger.shared.info("🔄 NotificationTopicManager: ======================================================")
                    return
                }

                Logger.shared.info("🔄 NotificationTopicManager: Topics actuales en preferencias: \(preferences.subscribedTopics)")

                // Sincronizar topics con favoritos actuales
                self.syncTopics(
                    favoriteTeamIds: favoriteTeamIds,
                    currentTopics: preferences.subscribedTopics
                )
                Logger.shared.info("🔄 NotificationTopicManager: ======================================================")
            }
            .store(in: &cancellables)

        Logger.shared.info("✅ NotificationTopicManager: Observación activa")
    }

    func stopObserving() {
        Logger.shared.info("⏹️ NotificationTopicManager: Deteniendo observación")
        cancellables.removeAll()
    }

    func syncTopicsWithFavorites() {
        Logger.shared.info("📋 NotificationTopicManager: ========== SINCRONIZACIÓN MANUAL ==========")
        Logger.shared.info("📋 NotificationTopicManager: Sincronizando topics con favoritos...")

        // Esperar un momento para que el listener de Firestore actualice el CurrentValueSubject
        // Luego obtener el valor actual directamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Obtener el valor actual directamente del CurrentValueSubject
            let favoriteTeamIds = self.favoritesService.getCurrentFavoriteTeams()
            Logger.shared.info("📋 NotificationTopicManager: Equipos favoritos obtenidos (valor actual): \(favoriteTeamIds)")
            
            // Obtener preferencias
            self.userPreferencesService.observePreferences()
                .first()
                .sink { [weak self] preferences in
                    guard let self = self else { return }
                    
                    Logger.shared.info("📋 NotificationTopicManager: Preferencias obtenidas: \(preferences != nil)")

                    // Si no hay preferencias, usar valores por defecto
                    let currentTopics = preferences?.subscribedTopics ?? []
                    let isEnabled = preferences?.pushNotificationsEnabled ?? true

                    Logger.shared.info("📋 NotificationTopicManager: Topics actuales: \(currentTopics), Notificaciones habilitadas: \(isEnabled)")

                    if isEnabled {
                        self.syncTopics(favoriteTeamIds: favoriteTeamIds, currentTopics: currentTopics)
                    } else {
                        Logger.shared.info("🔕 NotificationTopicManager: Notificaciones desactivadas - Saltando sincronización")
                    }
                    Logger.shared.info("📋 NotificationTopicManager: ==========================================")
                }
                .store(in: &self.cancellables)
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
        Logger.shared.info("🔄 NotificationTopicManager: Re-suscribiendo a topics guardados...")

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
                        Logger.shared.warning("⚠️ NotificationTopicManager: No hay preferencias guardadas")
                        return
                    }

                    Logger.shared.info("🔄 NotificationTopicManager: Re-suscribiendo a \(preferences.subscribedTopics.count) topics: \(preferences.subscribedTopics)")

                    // Re-suscribirse a todos los topics guardados
                    preferences.subscribedTopics.forEach { topic in
                        Logger.shared.info("🔄 NotificationTopicManager: Re-suscribiendo a topic: \(topic)")
                        self.notificationService.subscribeToTopic(topic)
                    }
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    /// Sincroniza los topics FCM con los favoritos actuales
    private func syncTopics(favoriteTeamIds: Set<String>, currentTopics: Set<String>) {
        Logger.shared.info("🔄 NotificationTopicManager: ========== SINCRONIZANDO TOPICS ==========")
        Logger.shared.info("🔄 NotificationTopicManager: Equipos favoritos recibidos: \(favoriteTeamIds)")
        Logger.shared.info("🔄 NotificationTopicManager: Topics actuales en preferencias: \(currentTopics)")
        
        // Convertir favoritos a topics (normalizar nombres)
        let desiredTopics = Set(favoriteTeamIds.map { topicName(for: $0) })
        Logger.shared.info("🔄 NotificationTopicManager: Topics deseados (generados): \(desiredTopics)")

        // Calcular diferencias
        let toSubscribe = desiredTopics.subtracting(currentTopics)
        let toUnsubscribe = currentTopics
            .subtracting(desiredTopics)
            .filter { $0.starts(with: "team_") } // No remover liga1_all

        Logger.shared.info("📊 NotificationTopicManager: Resumen de sincronización:")
        Logger.shared.info("   ➕ Topics a SUSCRIBIR: \(toSubscribe.isEmpty ? "NINGUNO" : toSubscribe.joined(separator: ", "))")
        Logger.shared.info("   ➖ Topics a DESUSCRIBIR: \(toUnsubscribe.isEmpty ? "NINGUNO" : toUnsubscribe.joined(separator: ", "))")

        // Aplicar cambios si hay diferencias
        if !toSubscribe.isEmpty || !toUnsubscribe.isEmpty {
            Logger.shared.info("🔄 NotificationTopicManager: Aplicando cambios de suscripción...")
            applyTopicChanges(subscribe: toSubscribe, unsubscribe: toUnsubscribe)
        } else {
            Logger.shared.info("✅ NotificationTopicManager: Topics ya sincronizados - Sin cambios necesarios")
            Logger.shared.info("   📋 Equipos favoritos: \(favoriteTeamIds)")
            Logger.shared.info("   📢 Topics suscritos: \(currentTopics)")
        }
        Logger.shared.info("🔄 NotificationTopicManager: ========================================")
    }

    /// Aplica cambios de suscripción/desuscripción a topics
    private func applyTopicChanges(subscribe: Set<String>, unsubscribe: Set<String>) {
        Logger.shared.info("🔄 NotificationTopicManager: Aplicando cambios de suscripción")
        Logger.shared.info("   ➕ Topics a suscribir: \(subscribe.isEmpty ? "ninguno" : subscribe.joined(separator: ", "))")
        Logger.shared.info("   ➖ Topics a desuscribir: \(unsubscribe.isEmpty ? "ninguno" : unsubscribe.joined(separator: ", "))")
        
        // Desuscribirse de topics que ya no son favoritos
        unsubscribe.forEach { topic in
            Logger.shared.info("🔕 NotificationTopicManager: Desuscribiendo de topic: '\(topic)'")
            notificationService.unsubscribeFromTopic(topic)
            removeTopicFromPreferences(topic)
        }

        // Suscribirse a nuevos topics
        subscribe.forEach { topic in
            Logger.shared.info("📢 NotificationTopicManager: Suscribiendo a topic: '\(topic)'")
            Logger.shared.info("   🔔 El dispositivo recibirá notificaciones push para: '\(topic)'")
            notificationService.subscribeToTopic(topic)
            addTopicToPreferences(topic)
        }
    }

    /// Agrega un topic a las preferencias de usuario en Firestore
    private func addTopicToPreferences(_ topic: String) {
        Logger.shared.info("💾 NotificationTopicManager: Agregando topic a preferencias: '\(topic)'")
        userPreferencesService.addSubscribedTopic(topic)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("❌ NotificationTopicManager: Error agregando topic '\(topic)' a preferencias", error: error)
                    } else {
                        Logger.shared.info("✅ NotificationTopicManager: Topic '\(topic)' agregado exitosamente a preferencias")
                    }
                },
                receiveValue: {
                    Logger.shared.info("💾 NotificationTopicManager: Topic '\(topic)' guardado en preferencias de usuario")
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
    /// IMPORTANTE: Normalizar a minúsculas porque los topics de FCM son case-sensitive
    /// Solo se necesita agregar el prefijo "team_"
    private func topicName(for teamId: String) -> String {
        // Normalizar a minúsculas para asegurar consistencia con el backend
        let normalizedTeamId = teamId.lowercased()
        let topic = "team_\(normalizedTeamId)"
        Logger.shared.info("🏷️ NotificationTopicManager: Generando topic para equipo")
        Logger.shared.info("   🏷️ TeamId recibido: '\(teamId)'")
        Logger.shared.info("   🔑 TeamId normalizado: '\(normalizedTeamId)'")
        Logger.shared.info("   📢 Topic generado: '\(topic)'")
        return topic
    }
}
