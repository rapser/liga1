//
//  AppEvent.swift
//  liga1
//
//  Eventos tipados de la app (EventBus).
//

import Foundation

/// Eventos de aplicación para el bus (logout, sesión, navegación).
/// Nota: loginSuccess fue eliminado — AppCoordinator observa AuthServiceProtocol directamente.
enum AppEvent {
    case logoutRequested
    case sessionExpired
    case navigateToMatch(matchId: String)
}
