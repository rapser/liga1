//
//  UserUI.swift
//  liga1
//
//  Auth/Presentation/Models: Modelo de presentación para usuario.
//  Created on 31/01/26.
//

import Foundation

/// Modelo de presentación para usuario (optimizado para UI)
struct UserUI {
    let id: String
    let displayName: String
    let email: String
    let avatarURL: String?
    let initials: String
    let isEmailVerified: Bool

    init(
        id: String,
        displayName: String,
        email: String,
        avatarURL: String?,
        initials: String,
        isEmailVerified: Bool
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.initials = initials
        self.isEmailVerified = isEmailVerified
    }
}
