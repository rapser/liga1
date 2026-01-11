//
//  ProfileViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine
import UIKit

class ProfileViewModel {

    // MARK: - Published Properties

    @Published private(set) var sections: [ProfileSection] = []
    @Published private(set) var currentTheme: UIUserInterfaceStyle = .unspecified
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published var logoutSuccessful: Bool = false

    // MARK: - Private Properties

    private let logoutUseCase: LogoutUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(logoutUseCase: LogoutUseCaseProtocol) {
        self.logoutUseCase = logoutUseCase
        loadCurrentTheme()
        setupSections()
    }

    // MARK: - Public Methods

    func logout() {
        isLoading = true
        error = nil

        logoutUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to logout", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.logoutSuccessful = true
            }
            .store(in: &cancellables)
    }

    func updateTheme(_ style: UIUserInterfaceStyle) {
        UserDefaults.standard.set(style.rawValue, forKey: "userInterfaceStyle")
        currentTheme = style
    }

    // MARK: - Private Methods

    private func loadCurrentTheme() {
        let savedStyle = UserDefaults.standard.integer(forKey: "userInterfaceStyle")
        currentTheme = UIUserInterfaceStyle(rawValue: savedStyle) ?? .unspecified
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
                )
            ]),
            ProfileSection(title: "Usuario", options: [
                ProfileOption(
                    title: "Nombre de usuario",
                    icon: UIImage(systemName: "person.fill"),
                    subtitle: nil,
                    action: .editUsername
                ),
                ProfileOption(
                    title: "Cerrar Sesión",
                    icon: UIImage(systemName: "arrow.backward.circle.fill"),
                    subtitle: nil,
                    action: .logout
                )
            ]),
            ProfileSection(title: "Tema", options: [
                ProfileOption(
                    title: "Modo Claro / Modo Oscuro",
                    icon: UIImage(systemName: "circle.lefthalf.fill"),
                    subtitle: nil,
                    action: .theme
                )
            ]),
            ProfileSection(title: "Administración", options: [
                ProfileOption(
                    title: "Registrar Partidos",
                    icon: UIImage(systemName: "football.fill"),
                    subtitle: "Herramienta para registro masivo",
                    action: .registrarPartidos
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
        case editUsername
        case logout
        case theme
        case feedback
        case terms
        case privacy
        case privacySettings
        case registrarPartidos
        case none
    }
}
