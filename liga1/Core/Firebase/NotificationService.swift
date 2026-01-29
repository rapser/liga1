//
//  NotificationService.swift
//  liga1
//
//  Created by miguel tomairo on 17/01/26.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

protocol NotificationServiceProtocol {
    func requestNotificationPermissions()
    func subscribeToTopic(_ topic: String)
    func unsubscribeFromTopic(_ topic: String)
    func handleNotificationToken(_ token: String)
}

final class NotificationService: NotificationServiceProtocol {

    // MARK: - Private Properties
    private var subscriptionRetryCount: [String: Int] = [:]
    private let maxRetries = 3

    // MARK: - Initialization
    init() {}

    // MARK: - Public Methods

    func requestNotificationPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                print("❌ Error solicitando permisos de notificación: \(error.localizedDescription)")
                return
            }

            if granted {
                print("✅ Permisos de notificación concedidos")

                // Registrar para notificaciones remotas en el main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Usuario rechazó permisos de notificación")
            }
        }
    }

    func subscribeToTopic(_ topic: String) {
        let apnsToken = Messaging.messaging().apnsToken
        if apnsToken == nil {
            let retryCount = subscriptionRetryCount[topic] ?? 0

            if retryCount >= maxRetries {
                subscriptionRetryCount.removeValue(forKey: topic)
                return
            }

            subscriptionRetryCount[topic] = retryCount + 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.subscribeToTopic(topic)
            }
            return
        }

        subscriptionRetryCount.removeValue(forKey: topic)

        Messaging.messaging().subscribe(toTopic: topic) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                Logger.shared.error("Error suscribiéndose a topic '\(topic)'", error: error)

                #if !targetEnvironment(simulator)
                let retryCount = self.subscriptionRetryCount[topic] ?? 0
                if retryCount < self.maxRetries {
                    self.subscriptionRetryCount[topic] = retryCount + 1
                    let errorDescription = error.localizedDescription.lowercased()
                    if errorDescription.contains("apns") || errorDescription.contains("token") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.subscribeToTopic(topic)
                        }
                    }
                } else {
                    self.subscriptionRetryCount.removeValue(forKey: topic)
                }
                #endif
            } else {
                self.subscriptionRetryCount.removeValue(forKey: topic)
            }
        }
    }

    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                Logger.shared.error("Error desuscribiéndose del topic \(topic)", error: error)
            }
        }
    }

    func handleNotificationToken(_ token: String) {
        print("🔑 Guardando FCM Token: \(token)")

        // Guardar el token en UserDefaults para referencia futura
        UserDefaults.standard.set(token, forKey: "fcm_token")

        print("Token guardado en UserDefaults")
    }
}
