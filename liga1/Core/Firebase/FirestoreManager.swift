//
//  FirestoreManager.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Singleton manager para acceso centralizado a Firestore
/// Elimina la duplicación de `Firestore.firestore()` en todo el proyecto
public final class FirestoreManager: DatabaseProtocol {

    // MARK: - Singleton

    public static let shared = FirestoreManager()

    // MARK: - Properties

    public let db: Firestore

    // MARK: - Initialization

    private init() {
        self.db = Firestore.firestore()
    }
}
