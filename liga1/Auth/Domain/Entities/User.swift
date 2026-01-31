//
//  User.swift
//  liga1
//
//  Auth/Domain/Entities: Entidad de dominio pura para usuario autenticado.
//  Created on 31/01/26.
//

import Foundation

/// Entidad de dominio para Usuario (sin dependencias de Firebase o UIKit)
public struct User {
    public let id: String
    public let email: String?
    public let displayName: String?
    public let photoURL: String?
    public let isEmailVerified: Bool

    public init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: String? = nil,
        isEmailVerified: Bool = false
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
    }
}

// MARK: - Equatable

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
