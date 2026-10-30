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
        // score_update debe procesarse siempre para mantener UI sincronizada con Firebase.
        if let type = userInfo[FirestoreConstants.PushPayload.type] as? String,
           type == FirestoreConstants.PushPayload.scoreUpdateType {
            Messaging.messaging().appDidReceiveMessage(userInfo)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .scoreUpdateReceived, object: nil)
            }
            refreshMatchesCache(for: userInfo, completionHandler: completionHandler)
            return
        }

        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                completionHandler(.noData)
                return
            }
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler(.newData)
    }

    /// Lee la jornada del push desde el servidor antes de devolver el control a iOS: así la caché
    /// persistente de Firestore ya tiene el marcador nuevo cuando el usuario abre la app.
    /// Si se llamara `completionHandler` de inmediato, iOS suspende la app antes de leer nada.
    private func refreshMatchesCache(
        for userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let jornadaId = userInfo[FirestoreConstants.PushPayload.jornadaId] as? String,
              !jornadaId.isEmpty else {
            completionHandler(.noData)
            return
        }

        // iOS concede ~30 s; el timeout garantiza responder aunque Firestore no conteste.
        var didComplete = false
        let finish: (UIBackgroundFetchResult) -> Void = { result in
            DispatchQueue.main.async {
                guard !didComplete else { return }
                didComplete = true
                completionHandler(result)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { finish(.failed) }

        DIContainer.shared.makeObserveMatchesUseCase().refresh(for: jornadaId) { success in
            finish(success ? .newData : .failed)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // score_update en foreground: actualizar en silencio siempre.
        if let type = userInfo[FirestoreConstants.PushPayload.type] as? String,
           type == FirestoreConstants.PushPayload.scoreUpdateType {
            Messaging.messaging().appDidReceiveMessage(userInfo)
            NotificationCenter.default.post(name: .scoreUpdateReceived, object: nil)
            completionHandler([])
            return
        }

        if let eventId = userInfo["event_id"] as? String {
            guard notificationDeduplicator.shouldShowNotification(eventId: eventId) else {
                completionHandler([])
                return
            }
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

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

