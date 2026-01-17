//
//  FavoritesService.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

protocol FavoritesServiceProtocol {
    // Matches
    func toggleFavorite(matchId: String) -> AnyPublisher<Bool, Error>
    func isFavorite(matchId: String) -> AnyPublisher<Bool, Never>
    func getAllFavorites() -> AnyPublisher<[String], Never>
    func observeFavorites() -> AnyPublisher<Set<String>, Never>

    // Teams
    func toggleFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Error>
    func isFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Never>
    func getAllFavoriteTeams() -> AnyPublisher<[String], Never>
    func observeFavoriteTeams() -> AnyPublisher<Set<String>, Never>
}

class FavoritesService: FavoritesServiceProtocol {

    private let database: DatabaseProtocol
    private let authProvider: AuthProvider
    private var favoritesListener: ListenerRegistration?
    private var favoriteTeamsListener: ListenerRegistration?

    // Subject para emitir cambios en tiempo real
    private let favoritesSubject = CurrentValueSubject<Set<String>, Never>([])
    private let favoriteTeamsSubject = CurrentValueSubject<Set<String>, Never>([])

    private var db: Firestore {
        database.db
    }

    init(database: DatabaseProtocol, authProvider: AuthProvider) {
        self.database = database
        self.authProvider = authProvider
        startObservingFavorites()
        startObservingFavoriteTeams()
    }

    deinit {
        favoritesListener?.remove()
        favoriteTeamsListener?.remove()
    }

    // MARK: - Private Helpers

    private func getUserId() -> String? {
        return authProvider.currentUserId
    }

    private func startObservingFavorites() {
        guard let userId = getUserId() else { return }

        favoritesListener = db.collection(FirestoreConstants.Collection.users)
            .document(userId)
            .collection(FirestoreConstants.Collection.favorites)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    Logger.shared.error("❌ Error listening to favorites", error: error)
                    return
                }

                let favoriteIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
                self?.favoritesSubject.send(favoriteIds)
            }
    }

    private func startObservingFavoriteTeams() {
        guard let userId = getUserId() else { return }

        favoriteTeamsListener = db.collection(FirestoreConstants.Collection.users)
            .document(userId)
            .collection("favoriteTeams")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    Logger.shared.error("❌ Error listening to favorite teams", error: error)
                    return
                }

                let favoriteTeamIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
                self?.favoriteTeamsSubject.send(favoriteTeamIds)
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

            let favRef = self.db.collection(FirestoreConstants.Collection.users).document(userId).collection(FirestoreConstants.Collection.favorites).document(matchId)

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

    // MARK: - Teams

    func toggleFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"])))
                return
            }

            guard let userId = self.getUserId() else {
                promise(.failure(NSError(domain: "FavoritesService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            let favRef = self.db.collection(FirestoreConstants.Collection.users).document(userId).collection("favoriteTeams").document(teamId)

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
                        "teamId": teamId,
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

    func isFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Never> {
        return favoriteTeamsSubject
            .map { $0.contains(teamId) }
            .eraseToAnyPublisher()
    }

    func getAllFavoriteTeams() -> AnyPublisher<[String], Never> {
        return favoriteTeamsSubject
            .map { Array($0) }
            .eraseToAnyPublisher()
    }

    func observeFavoriteTeams() -> AnyPublisher<Set<String>, Never> {
        return favoriteTeamsSubject
            .eraseToAnyPublisher()
    }
}
