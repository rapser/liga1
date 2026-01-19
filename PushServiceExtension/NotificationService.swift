//
//  NotificationService.swift
//  PushServiceExtension
//
//  Created by miguel tomairo on 17/01/26.
//

import UserNotifications

/// UNNotificationServiceExtension para manejar Rich Notifications
/// Permite modificar notificaciones remotas antes de mostrarlas al usuario
/// Principalmente usado para:
/// - Descargar y adjuntar imágenes
/// - Descargar y adjuntar videos
/// - Encriptar/desencriptar contenido
/// - Modificar el contenido de la notificación
class NotificationService: UNNotificationServiceExtension {

    // MARK: - Properties

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    // MARK: - UNNotificationServiceExtension

    /// Se llama cuando llega una notificación remota con "mutable-content": 1
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Log para debugging
        print("📮 [NotificationService] Procesando notificación rich")
        print("📮 [NotificationService] UserInfo: \(request.content.userInfo)")

        // Intentar obtener la URL de la imagen del payload
        if let imageUrlString = request.content.userInfo["image_url"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            print("📮 [NotificationService] Descargando imagen: \(imageUrlString)")
            downloadImage(from: imageUrl) { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    print("✅ [NotificationService] Imagen adjuntada exitosamente")
                } else {
                    print("❌ [NotificationService] Error al adjuntar imagen")
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            // No hay imagen, pero podemos modificar otros aspectos
            processNotificationContent(bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }

    /// Se llama justo antes de que el sistema termine la extensión
    /// Útil para limpiar recursos
    override func serviceExtensionTimeWillExpire() {
        print("⚠️ [NotificationService] Extension terminando")
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Private Methods

    /// Descarga una imagen desde una URL y la convierte en attachment
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempUrl, response, error in
            guard let tempUrl = tempUrl else {
                if let error = error {
                    print("❌ [NotificationService] Error descargando imagen: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }

            // Validar que sea una imagen
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ [NotificationService] Respuesta HTTP inválida")
                completion(nil)
                return
            }

            // Obtener extensión del archivo
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let fileName = "notification_image_\(UUID().uuidString).\(fileExtension)"

            // Crear URL temporal
            let fileManager = FileManager.default
            let localUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)

            do {
                // Mover el archivo descargado a una ubicación temporal
                if fileManager.fileExists(atPath: localUrl.path) {
                    try fileManager.removeItem(at: localUrl)
                }
                try fileManager.moveItem(at: tempUrl, to: localUrl)

                // Crear el attachment
                let attachment = try UNNotificationAttachment(
                    identifier: "notification_image",
                    url: localUrl
                )

                print("✅ [NotificationService] Imagen descargada y guardada: \(fileName)")
                completion(attachment)
            } catch {
                print("❌ [NotificationService] Error creando attachment: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }

    /// Procesa y modifica el contenido de la notificación
    private func processNotificationContent(_ content: UNMutableNotificationContent) {
        // Aquí puedes modificar título, body, badge, sound, etc.

        // Ejemplo: Agregar badge si viene en el payload
        if let badge = content.userInfo["badge"] as? Int {
            content.badge = NSNumber(value: badge)
        }

        // Ejemplo: Modificar el sonido
        if let customSound = content.userInfo["sound"] as? String {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: customSound))
        }

        // Ejemplo: Agregar información personalizada al subtitle
        if let matchInfo = content.userInfo["match_info"] as? String {
            content.subtitle = matchInfo
        }

        print("📝 [NotificationService] Contenido procesado")
    }
}
