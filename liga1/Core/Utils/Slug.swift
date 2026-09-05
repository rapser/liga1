//
//  Slug.swift
//  liga1
//

import Foundation

/// Slug determinista para IDs de documento (árbitros, jugadores, estadios).
/// minúsculas · sin diacríticos · `[^a-z0-9]` → "-" · colapsa y recorta "-".
/// El mismo string siempre produce el mismo slug (lookups estables en Firestore).
enum Slug {
    static func make(_ input: String) -> String {
        let folded = input.folding(options: .diacriticInsensitive,
                                   locale: Locale(identifier: "en_US_POSIX")).lowercased()
        var out = ""
        var pendingDash = false
        for scalar in folded.unicodeScalars {
            if (scalar >= "a" && scalar <= "z") || (scalar >= "0" && scalar <= "9") {
                if pendingDash, !out.isEmpty { out.append("-") }
                pendingDash = false
                out.unicodeScalars.append(scalar)
            } else {
                pendingDash = true
            }
        }
        return out
    }
}
