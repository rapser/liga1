//
//  UserMapper.swift
//  liga1
//
//  Auth/Data/Mappers: Mapper para convertir entre UserDTO y User (Domain).
//  Created on 31/01/26.
//

import Foundation
import FirebaseAuth

/// Mapper para convertir entre Data Layer (UserDTO) y Domain Layer (User)
struct UserMapper {

    /// Convierte UserDTO a User (Domain Model)
    static func toDomain(from dto: UserDTO) -> User {
        return User(
            id: dto.uid,
            email: dto.email,
            displayName: dto.displayName,
            photoURL: dto.photoURL?.absoluteString,
            isEmailVerified: dto.isEmailVerified
        )
    }

    /// Convierte directamente desde FirebaseAuth.User a User (Domain Model)
    static func toDomain(from firebaseUser: FirebaseAuth.User) -> User {
        let dto = UserDTO(from: firebaseUser)
        return toDomain(from: dto)
    }

    /// Convierte opcional de FirebaseAuth.User a opcional de User
    static func toDomainOptional(from firebaseUser: FirebaseAuth.User?) -> User? {
        guard let firebaseUser = firebaseUser else { return nil }
        return toDomain(from: firebaseUser)
    }
}
