//
//  GoogleCredential.swift
//  liga1
//
//  Domain: valor para autenticación con Google (sin UIKit).
//

import Foundation

/// Credencial de Google para firmar en Firebase (idToken + accessToken).
struct GoogleCredential {
    let idToken: String
    let accessToken: String
}
