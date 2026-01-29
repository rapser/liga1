//
//  UserPreferencesMapper.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation

/// Mapper para convertir entre UserPreferencesDTO y UserPreferences
enum UserPreferencesMapper {

    /// Convierte UserPreferencesDTO a UserPreferences (Domain Entity)
    static func toDomain(from dto: UserPreferencesDTO) -> UserPreferences {
        return UserPreferences(
            pushNotificationsEnabled: dto.pushNotificationsEnabled ?? true,
            subscribedTopics: Set(dto.subscribedTopics ?? []),
            updatedAt: dto.updatedAt?.dateValue() ?? Date()
        )
    }

    /// Convierte UserPreferences (Domain Entity) a Dictionary para Firestore
    static func toFirestoreData(from entity: UserPreferences) -> [String: Any] {
        return [
            "pushNotificationsEnabled": entity.pushNotificationsEnabled,
            "subscribedTopics": Array(entity.subscribedTopics),
            "updatedAt": entity.updatedAt
        ]
    }
}
