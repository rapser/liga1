//
//  ProfileViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//  Refactored on 15/02/26 to use AuthManager instead of LogoutUseCase.
//

import Foundation
import Combine
import UIKit

class ProfileViewModel {

    // MARK: - Published Properties

    @Published private(set) var sections: [ProfileSection] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published var logoutSuccessful: Bool = false

    // User profile data
    @Published private(set) var displayName: String = "Usuario"
    @Published private(set) var email: String = ""
    @Published private(set) var photoURL: String?
    @Published private(set) var profileImageData: Data?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupSections()
        observeAuthState()
    }

    // MARK: - Public Methods

    func logout() {
        isLoading = true
        error = nil

        // Llamar directamente a AuthManager
        AuthManager.shared.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.logoutSuccessful = true
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeAuthState() {
        AuthManager.shared.observeAuthState()
            .compactMap { $0 } // Solo cuando hay usuario
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateUserInfo(from: user)
            }
            .store(in: &cancellables)
    }

    private func updateUserInfo(from user: User) {
        // Actualizar display name
        self.displayName = user.displayName ?? "Usuario"

        // Actualizar email
        self.email = user.email ?? ""

        // Actualizar photo URL
        self.photoURL = user.photoURL

        // Descargar imagen de perfil si existe
        if let photoURLString = user.photoURL,
           let url = URL(string: photoURLString) {
            downloadProfileImage(from: url)
        } else {
            // Usar imagen por defecto
            self.profileImageData = nil
        }
    }

    private func downloadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self?.profileImageData = data
                }
            }
        }.resume()
    }

    private func setupSections() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
        let versionString = "\(appVersion) (\(buildNumber))"

        sections = [
            ProfileSection(title: "Notificaciones Push", options: [
                ProfileOption(
                    title: "Ajustes de notificaciones",
                    icon: UIImage(systemName: "bell.fill"),
                    subtitle: nil,
                    action: .notification
                ),
                ProfileOption(
                    title: "Historial de notificaciones",
                    icon: UIImage(systemName: "clock.fill"),
                    subtitle: nil,
                    action: .notificationHistory
                )
            ]),
            ProfileSection(title: "Usuario", options: [
                ProfileOption(
                    title: "Nombre de usuario",
                    icon: UIImage(systemName: "person.fill"),
                    subtitle: nil,
                    action: .editUsername
                )
            ]),
            ProfileSection(title: "Otros", options: [
                ProfileOption(
                    title: "Envía tus comentarios",
                    icon: UIImage(systemName: "envelope.fill"),
                    subtitle: nil,
                    action: .feedback
                ),
                ProfileOption(
                    title: "Condiciones de uso",
                    icon: UIImage(systemName: "doc.text.fill"),
                    subtitle: nil,
                    action: .terms
                ),
                ProfileOption(
                    title: "Políticas de privacidad",
                    icon: UIImage(systemName: "lock.shield.fill"),
                    subtitle: nil,
                    action: .privacy
                ),
                ProfileOption(
title: "Ajustes de privacidad",
                    icon: UIImage(systemName: "gearshape.fill"),
                    subtitle: nil,
                    action: .privacySettings
                ),
                ProfileOption(
                    title: "Versión",
                    icon: nil,
                    subtitle: versionString,
                    action: .none
                )
            ]),
            ProfileSection(title: "", options: [
                ProfileOption(
                    title: "Cerrar Sesión",
                    icon: UIImage(systemName: "arrow.backward.circle.fill"),
                    subtitle: nil,
                    action: .logout
                )
            ])
        ]
    }

    // MARK: - Nested Types

    struct ProfileSection {
        let title: String
        let options: [ProfileOption]
    }

    struct ProfileOption {
        let title: String
        let icon: UIImage?
        let subtitle: String?
        let action: ProfileAction
    }

    enum ProfileAction {
        case notification
        case notificationHistory
        case editUsername
        case logout
        case feedback
        case terms
        case privacy
        case privacySettings
        case none
    }
}
