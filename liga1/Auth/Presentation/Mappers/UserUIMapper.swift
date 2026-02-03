//
//  UserUIMapper.swift
//  liga1
//
//  Auth/Presentation/Mappers: Mapper para convertir User (Domain) a UserUI.
//  Created on 31/01/26.
//

import Foundation

/// Mapper para convertir entre Domain Layer (User) y Presentation Layer (UserUI)
struct UserUIMapper {

    /// Convierte User (Domain) a UserUI (Presentation)
    static func toUI(from domain: User) -> UserUI {
        // Generar iniciales del nombre
        let initials = generateInitials(from: domain.displayName)

        // Determinar el nombre a mostrar
        let displayName = domain.displayName ?? domain.email ?? "Usuario"

        return UserUI(
            id: domain.id,
            displayName: displayName,
            email: domain.email ?? "",
            avatarURL: domain.photoURL,
            initials: initials,
            isEmailVerified: domain.isEmailVerified
        )
    }

    /// Convierte opcional de User a opcional de UserUI
    static func toUIOptional(from domain: User?) -> UserUI? {
        guard let domain = domain else { return nil }
        return toUI(from: domain)
    }

    // MARK: - Private Helpers

    /// Genera iniciales a partir del nombre completo
    /// Ejemplo: "Juan Pérez" -> "JP"
    private static func generateInitials(from name: String?) -> String {
        guard let name = name, !name.isEmpty else {
            return "?"
        }

        let components = name.split(separator: " ")
        let initials = components
            .prefix(2)  // Tomar máximo 2 palabras
            .compactMap { $0.first }  // Obtener primera letra de cada palabra
            .map { String($0) }  // Convertir a String
            .joined()  // Unir
            .uppercased()  // Convertir a mayúsculas

        return initials.isEmpty ? "?" : initials
    }
}
