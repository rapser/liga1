//
//  UpdatePushNotificationsEnabledUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import Combine

protocol UpdatePushNotificationsEnabledUseCaseProtocol {
    func execute(enabled: Bool) -> AnyPublisher<Void, Error>
}

/// Use Case para activar/desactivar notificaciones push globalmente
/// Responsabilidades:
/// 1. Actualizar preferencia en Firestore
/// 2. Coordinar con NotificationTopicManager para sincronizar/desuscribir topics
class UpdatePushNotificationsEnabledUseCase: UpdatePushNotificationsEnabledUseCaseProtocol {

    private let userPreferencesService: UserPreferencesServiceProtocol
    private let notificationTopicManager: NotificationTopicManagerProtocol

    init(
        userPreferencesService: UserPreferencesServiceProtocol,
        notificationTopicManager: NotificationTopicManagerProtocol
    ) {
        self.userPreferencesService = userPreferencesService
        self.notificationTopicManager = notificationTopicManager
    }

    func execute(enabled: Bool) -> AnyPublisher<Void, Error> {
        Logger.shared.info("🔔 Actualizando notificaciones push: \(enabled ? "activadas" : "desactivadas")")

        return userPreferencesService.updatePushNotificationsEnabled(enabled)
            .handleEvents(
                receiveOutput: { [weak self] in
                    guard let self = self else { return }

                    if enabled {
                        // Re-suscribirse a topics guardados
                        Logger.shared.info("✅ Notificaciones activadas - Re-suscribiendo a topics")
                        self.notificationTopicManager.resubscribeToSavedTopics()
                    } else {
                        // Desuscribirse de todos los topics de equipos
                        Logger.shared.info("🔕 Notificaciones desactivadas - Desuscribiendo de topics")
                        self.notificationTopicManager.unsubscribeFromAllTeamTopics()
                    }
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Logger.shared.error("❌ Error actualizando notificaciones push", error: error)
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
