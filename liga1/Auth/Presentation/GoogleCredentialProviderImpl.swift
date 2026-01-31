//
//  GoogleCredentialProviderImpl.swift
//  liga1
//
//  Auth/Presentation: obtiene credencial de Google presentando la UI (GIDSignIn).
//

import Foundation
import Combine
import UIKit
import GoogleSignIn
import FirebaseCore

/// Implementación de GoogleCredentialProvider que presenta la UI de Google Sign-In.
final class GoogleCredentialProviderImpl: GoogleCredentialProvider {

    private weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func provideCredential() -> AnyPublisher<GoogleCredential, Error> {
        return Future<GoogleCredential, Error> { [weak self] promise in
            guard let self = self,
                  let presenting = self.presentingViewController else {
                promise(.failure(NSError(domain: "GoogleCredentialProviderImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController no disponible"])))
                return
            }
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                Logger.shared.error("❌ GoogleCredentialProviderImpl: No se pudo obtener clientID", error: nil)
                promise(.failure(NSError(domain: "GoogleCredentialProviderImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Error al configurar Google Sign In"])))
                return
            }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error = error {
                    Logger.shared.error("❌ GoogleCredentialProviderImpl: Error en Google Sign In", error: error)
                    promise(.failure(error))
                    return
                }
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    Logger.shared.error("❌ GoogleCredentialProviderImpl: No se pudo obtener credenciales", error: nil)
                    promise(.failure(NSError(domain: "GoogleCredentialProviderImpl", code: -3, userInfo: [NSLocalizedDescriptionKey: "Error al obtener credenciales de Google"])))
                    return
                }
                let credential = GoogleCredential(
                    idToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                promise(.success(credential))
            }
        }
        .eraseToAnyPublisher()
    }
}
