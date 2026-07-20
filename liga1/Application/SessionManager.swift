//
//  SessionManager.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//
//  Responsabilidad actual: bridge para notificaciones push y configuración de InactivityManager.
//  Auth y navegación por expiración de sesión se delegan a AppCoordinator via InactivityManager.
//

import UIKit

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private var inactivityManager: InactivityManager?

    /// Se invoca cuando el usuario toca una notificación push (matchId).
    var onNotificationTap: ((String) -> Void)?

    // MARK: - Configuración

    func configure(eventBus: AppEventBusProtocol) {
        inactivityManager = InactivityManager(eventBus: eventBus)
    }

    // MARK: - Inactividad

    func startInactivityTimer() {
        inactivityManager?.reset()
    }

    func resetTimer() {
        inactivityManager?.reset()
    }

    func stopTimer() {
        inactivityManager?.invalidate()
    }
}
