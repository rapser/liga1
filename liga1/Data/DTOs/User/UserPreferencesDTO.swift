//
//  UserPreferencesDTO.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para UserPreferences
/// Representa las preferencias de notificaciones en Firestore
struct UserPreferencesDTO: Codable {
    let pushNotificationsEnabled: Bool?
    let subscribedTopics: [String]?
    let updatedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case pushNotificationsEnabled
        case subscribedTopics
        case updatedAt
    }
}
