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
        Logger.shared.info("📡 NotificationService: Intentando suscribirse a topic: '\(topic)'")
        
        // Verificar si el token APNS está disponible
        let apnsToken = Messaging.messaging().apnsToken
        if apnsToken == nil {
            #if targetEnvironment(simulator)
            Logger.shared.info("⚠️ NotificationService: Token APNS no disponible (SIMULADOR)")
            Logger.shared.info("   ℹ️ Los simuladores pueden tener limitaciones con notificaciones push")
            Logger.shared.info("   ℹ️ Prueba en un dispositivo físico para verificar la funcionalidad completa")
            #else
            Logger.shared.info("⏳ NotificationService: Token APNS no disponible aún. Esperando...")
            #endif
            
            // Esperar un momento y reintentar (máximo 3 intentos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.subscribeToTopic(topic)
            }
            return
        }
        
        Logger.shared.info("✅ NotificationService: Token APNS disponible. Suscribiendo a topic: '\(topic)'")
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                Logger.shared.error("❌ NotificationService: Error suscribiéndose a topic '\(topic)'", error: error)
                
                #if targetEnvironment(simulator)
                Logger.shared.info("⚠️ NotificationService: Error en SIMULADOR")
                Logger.shared.info("   ℹ️ Los simuladores pueden tener limitaciones con FCM topics")
                Logger.shared.info("   ℹ️ Prueba en un dispositivo físico para verificar la funcionalidad completa")
                #endif
                
                // Si el error es por falta de token APNS, reintentar después de un delay
                let errorDescription = error.localizedDescription.lowercased()
                if errorDescription.contains("apns") || errorDescription.contains("token") {
                    Logger.shared.info("🔄 NotificationService: Reintentando suscripción después de 3 segundos...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        self?.subscribeToTopic(topic)
                    }
                }
            } else {
                Logger.shared.info("✅ NotificationService: ✅ SUSCRITO EXITOSAMENTE A TOPIC: '\(topic)'")
                Logger.shared.info("   📱 El dispositivo ahora recibirá notificaciones push para este topic")
            }
        }
    }

    func unsubscribeFromTopic(_ topic: String) {
        Logger.shared.info("📡 NotificationService: Intentando desuscribirse del topic: \(topic)")
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                Logger.shared.error("❌ Error desuscribiéndose del topic \(topic)", error: error)
            } else {
                Logger.shared.info("✅ NotificationService: Desuscrito exitosamente del topic: \(topic)")
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
