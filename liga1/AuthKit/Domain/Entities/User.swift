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
    public let phoneNumber: String?
    public let isEmailVerified: Bool
    public let creationDate: Date?
    public let lastSignInDate: Date?
    public let providerID: String?  // "google.com", "password", etc.

    public init(
        id: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        phoneNumber: String? = nil,
        isEmailVerified: Bool,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        providerID: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.isEmailVerified = isEmailVerified
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.providerID = providerID
    }

    // MARK: - Equatable

    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
