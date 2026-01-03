//
//  FavoritesService.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

protocol FavoritesServiceProtocol {
    func toggleFavorite(matchId: String) -> AnyPublisher<Bool, Error>
    func isFavorite(matchId: String) -> AnyPublisher<Bool, Never>
    func getAllFavorites() -> AnyPublisher<[String], Never>
    func observeFavorites() -> AnyPublisher<Set<String>, Never>
}

class FavoritesService: FavoritesServiceProtocol {

    private let db = Firestore.firestore()
    private var favoritesListener: ListenerRegistration?

    // Subject para emitir cambios en tiempo real
    private let favoritesSubject = CurrentValueSubject<Set<String>, Never>([])

    init() {
        startObservingFavorites()
    }

    deinit {
        favoritesListener?.remove()
    }

    // MARK: - Private Helpers

    private func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }

    private func startObservingFavorites() {
        guard let userId = getUserId() else { return }

        favoritesListener = db.collection("users")
            .document(userId)
            .collection("favoritos")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error listening to favorites: \(error)")
                    return
                }

                let favoriteIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
                self?.favoritesSubject.send(favoriteIds)
            }
    }

    // MARK: - Protocol Implementation

    func toggleFavorite(matchId: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"])))
                return
            }

            guard let userId = self.getUserId() else {
                promise(.failure(NSError(domain: "FavoritesService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            let favRef = self.db.collection("users").document(userId).collection("favoritos").document(matchId)

            favRef.getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                if snapshot?.exists == true {
                    // Ya es favorito, eliminar
                    favRef.delete { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(false))
                        }
                    }
                } else {
                    // No es favorito, agregar
                    favRef.setData([
                        "matchId": matchId,
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(true))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func isFavorite(matchId: String) -> AnyPublisher<Bool, Never> {
        return favoritesSubject
            .map { $0.contains(matchId) }
            .eraseToAnyPublisher()
    }

    func getAllFavorites() -> AnyPublisher<[String], Never> {
        return favoritesSubject
            .map { Array($0) }
            .eraseToAnyPublisher()
    }

    func observeFavorites() -> AnyPublisher<Set<String>, Never> {
        return favoritesSubject
            .eraseToAnyPublisher()
    }
}
