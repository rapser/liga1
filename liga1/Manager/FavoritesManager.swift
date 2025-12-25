//
//  FavoritesManager.swift
//  liga1
//
//  Created by Claude on 24/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FavoritesManager {

    static let shared = FavoritesManager()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Get User ID
    private func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Toggle Favorite
    func toggleFavorite(matchId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = getUserId() else {
            completion(false, NSError(domain: "FavoritesManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"]))
            return
        }

        let favRef = db.collection("users").document(userId).collection("favoritos").document(matchId)

        favRef.getDocument { snapshot, error in
            if let error = error {
                completion(false, error)
                return
            }

            if snapshot?.exists == true {
                // Ya es favorito, eliminar
                favRef.delete { error in
                    completion(false, error)
                }
            } else {
                // No es favorito, agregar
                favRef.setData([
                    "matchId": matchId,
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    completion(true, error)
                }
            }
        }
    }

    // MARK: - Check if Favorite
    func isFavorite(matchId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = getUserId() else {
            completion(false)
            return
        }

        db.collection("users").document(userId).collection("favoritos").document(matchId)
            .getDocument { snapshot, error in
                completion(snapshot?.exists == true)
            }
    }

    // MARK: - Get All Favorites
    func getAllFavorites(completion: @escaping ([String]) -> Void) {
        guard let userId = getUserId() else {
            completion([])
            return
        }

        db.collection("users").document(userId).collection("favoritos")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching favorites: \(error)")
                    completion([])
                    return
                }

                let favoriteIds = snapshot?.documents.compactMap { $0.documentID } ?? []
                completion(favoriteIds)
            }
    }

    // MARK: - Listen to Favorites (Real-time)
    func listenToFavorites(completion: @escaping ([String]) -> Void) -> ListenerRegistration? {
        guard let userId = getUserId() else {
            completion([])
            return nil
        }

        return db.collection("users").document(userId).collection("favoritos")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to favorites: \(error)")
                    completion([])
                    return
                }

                let favoriteIds = snapshot?.documents.compactMap { $0.documentID } ?? []
                completion(favoriteIds)
            }
    }
}
