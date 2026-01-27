//
//  AppDelegate.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UserNotifications
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate,
                   UNUserNotificationCenterDelegate,
                   MessagingDelegate {

    // MARK: - Properties

    var notificationTopicManager: NotificationTopicManagerProtocol?
    private lazy var notificationDeduplicator = DIContainer.shared.makeNotificationDeduplicator()

    // MARK: - Lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // Habilitar persistencia offline de Firestore
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        // Configurar delegates de notificaciones
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        // Solicitar permisos de notificaciones
        let notificationService = DIContainer.shared.makeNotificationService()
        notificationService.requestNotificationPermissions()

        // Registrar para notificaciones remotas
        application.registerForRemoteNotifications()

        // NUEVO: Inicializar NotificationTopicManager
        let topicManager = DIContainer.shared.makeNotificationTopicManager()
        topicManager.startObserving()
        self.notificationTopicManager = topicManager

        // Limpiar badge al abrir la app
        clearBadge()

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Limpiar badge cuando la app se vuelve activa
        clearBadge()
    }
    
    // MARK: - Badge Management
    
    private func clearBadge() {
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
            } catch {
                Logger.shared.error("Error al limpiar badge", error: error)
            }
        }
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    // MARK: - Remote Notifications Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Logger.shared.info("📱 Device Token APNs: \(token)")

        // Pasar el token a Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.shared.error("❌ Error al registrar notificaciones remotas", error: error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Logger.shared.info("📮 Notificación remota recibida en background: \(userInfo)")

        // NUEVO: Verificar si es duplicado usando event_id
        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                Logger.shared.debug("⚠️ Notificación duplicada ignorada (background): \(eventId)")
                completionHandler(.noData)
                return
            }
        }

        // Procesar la notificación normalmente
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Aquí puedes actualizar datos en background
        // Por ejemplo: sincronizar marcadores de partidos

        completionHandler(.newData)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Logger.shared.info("📬 Notificación recibida en foreground: \(userInfo)")

        // NUEVO: Verificar si es duplicado usando event_id
        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                Logger.shared.debug("⚠️ Notificación duplicada ignorada (foreground): \(eventId)")
                completionHandler([])
                return
            }
        }

        // Procesar la notificación normalmente
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Mostrar banner, sonido y badge incluso en foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Logger.shared.info("👆 Usuario tocó notificación: \(userInfo)")

        // NUEVO: Verificar si es duplicado usando event_id
        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                Logger.shared.debug("⚠️ Tap en notificación duplicada ignorado: \(eventId)")
                completionHandler()
                return
            }
        }

        // Manejar tap en notificación
        handleNotificationTap(userInfo: userInfo)

        completionHandler()
    }

    // MARK: - MessagingDelegate

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }

        Logger.shared.info("🔑 FCM Token recibido: \(token)")

        let notificationService = DIContainer.shared.makeNotificationService()
        notificationService.handleNotificationToken(token)

        // Suscribirse a topic general de la liga (siempre activo)
        Logger.shared.info("📢 AppDelegate: Suscribiendo a topic liga1_all")
        notificationService.subscribeToTopic("liga1_all")

        // Sincronizar topics con favoritos de equipos
        Logger.shared.info("🔄 AppDelegate: Sincronizando topics con favoritos")
        let topicManager = DIContainer.shared.makeNotificationTopicManager()
        topicManager.syncTopicsWithFavorites()
        
        // También re-suscribirse a topics guardados por si acaso
        Logger.shared.info("🔄 AppDelegate: Re-suscribiendo a topics guardados")
        topicManager.resubscribeToSavedTopics()
    }

    // MARK: - Private Helpers

    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Parsear datos de la notificación
        guard let matchId = userInfo["matchId"] as? String,
              let type = userInfo["type"] as? String else {
            return
        }

        Logger.shared.debug("Procesando notificación - Type: \(type), Match: \(matchId)")

        // Notificar al AppCoordinator para navegar
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToMatch"),
            object: nil,
            userInfo: ["matchId": matchId]
        )
    }
}

