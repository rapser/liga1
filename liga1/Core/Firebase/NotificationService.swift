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
        Logger.shared.info("📡 NotificationService: ========== SUSCRIPCIÓN A TOPIC ==========")
        Logger.shared.info("📡 NotificationService: Intentando suscribirse a topic: '\(topic)'")
        
        // Verificar si el token APNS está disponible
        let apnsToken = Messaging.messaging().apnsToken
        if apnsToken == nil {
            let retryCount = subscriptionRetryCount[topic] ?? 0
            
            if retryCount >= maxRetries {
                Logger.shared.error("❌ NotificationService: Máximo de reintentos alcanzado para topic '\(topic)'", error: nil)
                Logger.shared.info("   ⚠️ No se pudo suscribir después de \(maxRetries) intentos")
                Logger.shared.info("   ℹ️ Verifica que el token APNS esté disponible")
                Logger.shared.info("📡 NotificationService: ======================================")
                subscriptionRetryCount.removeValue(forKey: topic)
                return
            }
            
            subscriptionRetryCount[topic] = retryCount + 1
            
            #if targetEnvironment(simulator)
            Logger.shared.info("⚠️ NotificationService: Token APNS no disponible (SIMULADOR) - Intento \(retryCount + 1)/\(maxRetries)")
            Logger.shared.info("   ℹ️ Los simuladores NO pueden recibir notificaciones push reales")
            Logger.shared.info("   ℹ️ NECESITAS probar en un DISPOSITIVO FÍSICO (iPhone/iPad real)")
            Logger.shared.info("   ℹ️ El simulador no tiene token APNS válido de Apple")
            #else
            Logger.shared.info("⏳ NotificationService: Token APNS no disponible aún - Intento \(retryCount + 1)/\(maxRetries)")
            Logger.shared.info("   ℹ️ Esperando a que el token APNS se registre...")
            #endif
            
            // Esperar un momento y reintentar
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.subscribeToTopic(topic)
            }
            Logger.shared.info("📡 NotificationService: ======================================")
            return
        }
        
        // Resetear contador de reintentos si el token está disponible
        subscriptionRetryCount.removeValue(forKey: topic)
        
        // Verificar token FCM
        Messaging.messaging().token { token, error in
            if let error = error {
                Logger.shared.error("❌ NotificationService: Error obteniendo token FCM", error: error)
                Logger.shared.info("📡 NotificationService: ======================================")
                return
            }
            
            if let fcmToken = token {
                Logger.shared.info("✅ NotificationService: Token FCM disponible: \(fcmToken.prefix(20))...")
            } else {
                Logger.shared.info("⚠️ NotificationService: Token FCM no disponible")
            }
        }
        
        Logger.shared.info("✅ NotificationService: Token APNS disponible. Suscribiendo a topic: '\(topic)'")
        #if !targetEnvironment(simulator)
        Logger.shared.info("   📱 Dispositivo físico detectado - Token APNS válido")
        #endif
        
        Messaging.messaging().subscribe(toTopic: topic) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                Logger.shared.error("❌ NotificationService: Error suscribiéndose a topic '\(topic)'", error: error)
                Logger.shared.info("   Detalles: \(error.localizedDescription)")
                
                #if targetEnvironment(simulator)
                Logger.shared.info("⚠️ NotificationService: Error en SIMULADOR")
                Logger.shared.info("   ⚠️ IMPORTANTE: Los simuladores NO pueden recibir notificaciones push")
                Logger.shared.info("   ⚠️ NECESITAS un DISPOSITIVO FÍSICO para probar notificaciones push")
                Logger.shared.info("   ⚠️ El simulador no tiene token APNS válido de Apple")
                #else
                let retryCount = self.subscriptionRetryCount[topic] ?? 0
                if retryCount < self.maxRetries {
                    self.subscriptionRetryCount[topic] = retryCount + 1
                    // Si el error es por falta de token APNS, reintentar después de un delay
                    let errorDescription = error.localizedDescription.lowercased()
                    if errorDescription.contains("apns") || errorDescription.contains("token") {
                        Logger.shared.info("🔄 NotificationService: Reintentando suscripción después de 3 segundos... (Intento \(retryCount + 1)/\(self.maxRetries))")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.subscribeToTopic(topic)
                        }
                    }
                } else {
                    Logger.shared.error("❌ NotificationService: Máximo de reintentos alcanzado para topic '\(topic)'", error: nil)
                    self.subscriptionRetryCount.removeValue(forKey: topic)
                }
                #endif
            } else {
                Logger.shared.info("✅ NotificationService: ✅✅✅ SUSCRITO EXITOSAMENTE A TOPIC: '\(topic)' ✅✅✅")
                Logger.shared.info("   📱 El dispositivo ahora recibirá notificaciones push para este topic")
                Logger.shared.info("   📬 Prueba enviando un push desde el admin web a '\(topic)'")
                self.subscriptionRetryCount.removeValue(forKey: topic)
            }
            Logger.shared.info("📡 NotificationService: ======================================")
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
