//
//  NotificationDeduplicator.swift
//  liga1
//
//  Created by miguel tomairo on 27/01/26.
//

import Foundation

/// Protocolo para el deduplicador de notificaciones
protocol NotificationDeduplicatorProtocol {
    /// Verifica si una notificación debe mostrarse (no es duplicado)
    /// - Parameter eventId: ID único del evento
    /// - Returns: true si debe mostrarse, false si es duplicado
    func shouldShowNotification(eventId: String) -> Bool

    /// Limpia el cache de event IDs antiguos
    func cleanup()
}

/// Deduplicador de notificaciones push usando cache en memoria
final class NotificationDeduplicator: NotificationDeduplicatorProtocol {

    // MARK: - Properties

    private var receivedEventIds: Set<String> = []
    private let deduplicationWindow: TimeInterval = 5.0 // 5 segundos
    private let queue = DispatchQueue(label: "com.rapser.liga1.notificationDeduplicator", attributes: .concurrent)

    // MARK: - Public Methods

    func shouldShowNotification(eventId: String) -> Bool {
        var shouldShow = false

        queue.sync(flags: .barrier) {
            // Verificar si ya existe
            if receivedEventIds.contains(eventId) {
                Logger.shared.debug("⚠️ Notificación duplicada ignorada: \(eventId)")
                shouldShow = false
                return
            }

            // Agregar a la lista
            receivedEventIds.insert(eventId)
            Logger.shared.debug("✅ Notificación nueva recibida: \(eventId)")
            shouldShow = true

            // Programar eliminación después del tiempo de ventana
            DispatchQueue.main.asyncAfter(deadline: .now() + deduplicationWindow) { [weak self] in
                self?.removeEventId(eventId)
            }
        }

        return shouldShow
    }

    func cleanup() {
        queue.async(flags: .barrier) { [weak self] in
            self?.receivedEventIds.removeAll()
            Logger.shared.debug("🧹 Cache de notificaciones limpiado")
        }
    }

    // MARK: - Private Methods

    private func removeEventId(_ eventId: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.receivedEventIds.remove(eventId)
            Logger.shared.debug("🗑️ Event ID expirado removido: \(eventId)")
        }
    }
}
