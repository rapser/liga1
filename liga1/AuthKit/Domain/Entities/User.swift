//
//  User.swift
//  liga1
//
//  AuthKit/Domain/Entities: Entidad de dominio para usuario autenticado.
//  Created on 15/02/26.
//

import Foundation

/// Entidad de dominio que representa un usuario autenticado
/// Sin dependencias de Firebase, UIKit, ni detalles de implementación
public struct User: Equatable {
    public let id: String
    public let email: String?
    public let displayName: String?
    public let photoURL: String?
    public let isEmailVerified: Bool

    public init(
        id: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        isEmailVerified: Bool
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
    }

    // MARK: - Equatable

    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
