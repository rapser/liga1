//
//  GoogleCredentialProvider.swift
//  liga1
//
//  Domain: abstracción para obtener credencial de Google (la UI vive en Presentation).
//

import Foundation
import Combine

/// Proveedor de credencial de Google. La implementación (presentar UI, GIDSignIn) vive en Presentation.
protocol GoogleCredentialProvider {
    func provideCredential() -> AnyPublisher<GoogleCredential, Error>
}
