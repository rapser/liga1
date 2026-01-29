//
//  UserPreferences.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation

/// Domain entity que representa las preferencias de notificaciones del usuario
struct UserPreferences {
    let pushNotificationsEnabled: Bool
    let subscribedTopics: Set<String>
    let updatedAt: Date

    /// Inicializador con valores por defecto
    init(
        pushNotificationsEnabled: Bool = true,
        subscribedTopics: Set<String> = [],
        updatedAt: Date = Date()
    ) {
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.subscribedTopics = subscribedTopics
        self.updatedAt = updatedAt
    }
}
