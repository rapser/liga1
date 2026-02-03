//
//  UserDTO.swift
//  liga1
//
//  Auth/Data/DTOs: Data Transfer Object para usuario de Firebase.
//  Created on 31/01/26.
//

import Foundation
import FirebaseAuth

/// DTO para transferir datos de usuario desde Firebase Auth
struct UserDTO {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    let isEmailVerified: Bool

    /// Inicializar desde un usuario de Firebase Auth
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL
        self.isEmailVerified = firebaseUser.isEmailVerified
    }
}
