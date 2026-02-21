//
//  FirebaseUserMapper.swift
//  liga1
//
//  AuthKit/Providers/Firebase: Mapper para convertir FirebaseAuth.User a User (domain).
//  Migrado desde UserMapper.swift - Created on 15/02/26.
//

import Foundation
import FirebaseAuth

/// Mapper para convertir usuarios de Firebase Auth a entidades de dominio
struct FirebaseUserMapper {

    /// Convierte directamente desde FirebaseAuth.User a User (Domain Model)
    /// - Parameter firebaseUser: Usuario de Firebase Auth
    /// - Returns: Usuario de dominio
    static func toDomain(from firebaseUser: FirebaseAuth.User) -> User {
        // Obtener el proveedor principal (el primero en la lista)
        let primaryProvider = firebaseUser.providerData.first?.providerID

        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL?.absoluteString,
            phoneNumber: firebaseUser.phoneNumber,
            isEmailVerified: firebaseUser.isEmailVerified,
            creationDate: firebaseUser.metadata.creationDate,
            lastSignInDate: firebaseUser.metadata.lastSignInDate,
            providerID: primaryProvider
        )
    }

    /// Convierte opcional de FirebaseAuth.User a opcional de User
    /// - Parameter firebaseUser: Usuario de Firebase Auth (opcional)
    /// - Returns: Usuario de dominio (opcional)
    static func toDomainOptional(from firebaseUser: FirebaseAuth.User?) -> User? {
        guard let firebaseUser = firebaseUser else { return nil }
        return toDomain(from: firebaseUser)
    }
}
