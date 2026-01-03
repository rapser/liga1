//
//  LoginViewModel.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewModel {

    // MARK: - Published Properties

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published var loginSuccessful: Bool = false

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    // MARK: - Public Methods

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            error = "Por favor completa todos los campos"
            return
        }

        isLoading = true
        error = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }

                self?.loginSuccessful = true
            }
        }
    }

    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            error = "Error al configurar Google Sign In"
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error = error {
                self?.error = error.localizedDescription
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self?.error = "Error al obtener credenciales de Google"
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                          accessToken: user.accessToken.tokenString)

            self?.isLoading = true

            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    if let error = error {
                        self?.error = error.localizedDescription
                        return
                    }

                    self?.loginSuccessful = true
                }
            }
        }
    }

    func clearError() {
        error = nil
    }
}
