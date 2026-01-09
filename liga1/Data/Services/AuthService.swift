//
//  AuthService.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import Combine
import UIKit

protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<Void, Error>
    func loginWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<Void, Error>
    func logout() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> AnyPublisher<User?, Never>
}

class AuthService: AuthServiceProtocol, AuthProvider {

    // MARK: - AuthProvider

    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func loginWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                let error = NSError(
                    domain: "AuthService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Error al configurar Google Sign In"]
                )
                promise(.failure(error))
                return
            }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    let error = NSError(
                        domain: "AuthService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Error al obtener credenciales de Google"]
                    )
                    promise(.failure(error))
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func getCurrentUser() -> AnyPublisher<User?, Never> {
        return Just(Auth.auth().currentUser)
            .eraseToAnyPublisher()
    }
}
