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
        // 1. Configurar Firebase (debe ser primero)
        FirebaseApp.configure()

        // 2. Configurar AuthKit con Firebase (reutiliza la configuración de Firebase)
        AuthManager.shared.configure(provider: .firebase)

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
                DIContainer.shared.makeLogger().error("Error al limpiar badge", error: error)
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
        Messaging.messaging().apnsToken = deviceToken

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if let topicManager = self?.notificationTopicManager {
                topicManager.syncTopicsWithFavorites()
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        DIContainer.shared.makeLogger().error("Error al registrar notificaciones remotas", error: error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                completionHandler(.noData)
                return
            }
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Data-only push de actualización de marcador
        if let type = userInfo[FirestoreConstants.PushPayload.type] as? String,
           type == FirestoreConstants.PushPayload.scoreUpdateType {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .scoreUpdateReceived, object: nil)
            }
            completionHandler(.newData)
            return
        }

        completionHandler(.newData)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                completionHandler([])
                return
            }
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Si es actualización de marcador: no mostrar banner y actualizar en silencio
        if let type = userInfo[FirestoreConstants.PushPayload.type] as? String,
           type == FirestoreConstants.PushPayload.scoreUpdateType {
            NotificationCenter.default.post(name: .scoreUpdateReceived, object: nil)
            completionHandler([])
            return
        }

        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                completionHandler()
                return
            }
        }

        handleNotificationTap(userInfo: userInfo)
        completionHandler()
    }

    // MARK: - MessagingDelegate

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }

        let notificationService = DIContainer.shared.makeNotificationService()
        notificationService.handleNotificationToken(token)
        notificationService.subscribeToTopic("liga1_all")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let topicManager = DIContainer.shared.makeNotificationTopicManager()
            topicManager.syncTopicsWithFavorites()
            topicManager.resubscribeToSavedTopics()
        }
    }

    // MARK: - Private Helpers

    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let matchId = userInfo["matchId"] as? String else {
            return
        }
        SessionManager.shared.onNotificationTap?(matchId)
    }
}

