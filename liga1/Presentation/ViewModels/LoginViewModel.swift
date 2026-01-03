//
//  LoginViewModel.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine
import UIKit

class LoginViewModel {

    // MARK: - Published Properties

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published var loginSuccessful: Bool = false

    // MARK: - Dependencies

    private let loginUseCase: LoginUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    // MARK: - Public Methods

    func login(email: String, password: String) {
        isLoading = true
        error = nil

        Logger.shared.debug("Attempting login for email: \(email)")

        loginUseCase.execute(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Login failed for email: \(email)", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                Logger.shared.info("User logged in successfully with email: \(email)")
                self?.loginSuccessful = true
            }
            .store(in: &cancellables)
    }

    func signInWithGoogle(presentingViewController: UIViewController) {
        isLoading = true
        error = nil

        Logger.shared.debug("Attempting Google Sign In")

        loginUseCase.executeWithGoogle(presentingViewController: presentingViewController)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Google Sign In failed", error: error)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                Logger.shared.info("User logged in successfully with Google")
                self?.loginSuccessful = true
            }
            .store(in: &cancellables)
    }

    func clearError() {
        error = nil
    }
}
