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
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("❌ Error suscribiéndose a topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Suscrito exitosamente a topic: \(topic)")
            }
        }
    }

    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("❌ Error desuscribiéndose del topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Desuscrito exitosamente del topic: \(topic)")
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
