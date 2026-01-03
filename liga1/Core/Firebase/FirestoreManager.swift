//
//  FirestoreManager.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Singleton manager para acceso centralizado a Firestore
/// Elimina la duplicación de `Firestore.firestore()` en todo el proyecto
final class FirestoreManager {

    // MARK: - Singleton

    static let shared = FirestoreManager()

    // MARK: - Properties

    let db: Firestore

    // MARK: - Initialization

    private init() {
        self.db = Firestore.firestore()
    }
}
