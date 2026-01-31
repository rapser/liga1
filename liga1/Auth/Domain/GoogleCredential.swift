//
//  GoogleCredential.swift
//  liga1
//
//  Auth/Domain: valor para autenticación con Google (sin UIKit).
//

import Foundation

/// Credencial de Google para firmar en Firebase (idToken + accessToken).
public struct GoogleCredential {
    public let idToken: String
    public let accessToken: String

    public init(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }
}
