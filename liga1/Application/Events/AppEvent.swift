//
//  AppEvent.swift
//  liga1
//
//  Eventos tipados de la app (EventBus).
//

import Foundation

/// Eventos de aplicación para el bus (login, logout, navegación).
enum AppEvent {
    case loginSuccess
    case logoutRequested
    case navigateToMatch(matchId: String)
}
