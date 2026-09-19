//
//  NotificationSettingsViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import Combine

class NotificationSettingsViewModel {

    // MARK: - Published Properties

    @Published private(set) var pushNotificationsEnabled: Bool = true
    @Published private(set) var leagueWideLiveNotificationsEnabled: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let updatePushNotificationsEnabledUseCase: UpdatePushNotificationsEnabledUseCaseProtocol
    private let observeUserPreferencesUseCase: ObserveUserPreferencesUseCaseProtocol
    private let notificationTopicManager: NotificationTopicManagerProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        updatePushNotificationsEnabledUseCase: UpdatePushNotificationsEnabledUseCaseProtocol,
        observeUserPreferencesUseCase: ObserveUserPreferencesUseCaseProtocol,
        notificationTopicManager: NotificationTopicManagerProtocol
    ) {
        self.updatePushNotificationsEnabledUseCase = updatePushNotificationsEnabledUseCase
        self.observeUserPreferencesUseCase = observeUserPreferencesUseCase
        self.notificationTopicManager = notificationTopicManager

        observePreferences()
    }

    // MARK: - Public Methods

    func updatePushNotificationsEnabled(_ enabled: Bool) {
        isLoading = true
        errorMessage = nil

        updatePushNotificationsEnabledUseCase.execute(enabled: enabled)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    if case .failure = completion {
                        self?.errorMessage = "No se pudo actualizar la configuración. Intenta nuevamente."

                        // Revertir el cambio en la UI
                        self?.pushNotificationsEnabled = !enabled
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func updateLeagueWideLiveNotifications(_ enabled: Bool) {
        notificationTopicManager.setLeagueWideLiveNotifications(enabled: enabled)
        leagueWideLiveNotificationsEnabled = enabled
    }

    // MARK: - Private Methods

    private func observePreferences() {
        observeUserPreferencesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preferences in
                // Si no hay preferencias, usar valores por defecto
                self?.pushNotificationsEnabled = preferences?.pushNotificationsEnabled ?? true
                self?.leagueWideLiveNotificationsEnabled = preferences?.subscribedTopics.contains("liga1_live") ?? false
            }
            .store(in: &cancellables)
    }
}
