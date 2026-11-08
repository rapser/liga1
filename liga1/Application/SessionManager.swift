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

    /// Se invoca cuando el usuario toca una notificación de partido.
    /// Si el tap llega antes de que la escena configure el handler (arranque en frío),
    /// se guarda y se entrega en cuanto se asigna.
    var onNotificationTap: ((MatchRoute) -> Void)? {
        didSet {
            guard let handler = onNotificationTap, let route = pendingRoute else { return }
            pendingRoute = nil
            handler(route)
        }
    }
    private var pendingRoute: MatchRoute?

    func handleNotificationTap(_ route: MatchRoute) {
        if let handler = onNotificationTap {
            handler(route)
        } else {
            pendingRoute = route
        }
    }

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
