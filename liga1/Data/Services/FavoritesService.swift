//
//  FavoritesService.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol FavoritesServiceProtocol {
    // Matches
    func toggleFavorite(matchId: String) -> AnyPublisher<Bool, Error>
    func fetchFavorites() -> AnyPublisher<Void, Error>
    func isFavorite(matchId: String) -> AnyPublisher<Bool, Never>
    func getAllFavorites() -> AnyPublisher<[String], Never>
    func observeFavorites() -> AnyPublisher<Set<String>, Never>
    func getCurrentFavoriteTeams() -> Set<String>

    // Teams
    func toggleFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Error>
    func fetchFavoriteTeams() -> AnyPublisher<Void, Error>
    func isFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Never>
    func getAllFavoriteTeams() -> AnyPublisher<[String], Never>
    func observeFavoriteTeams() -> AnyPublisher<Set<String>, Never>
}

class FavoritesService: FavoritesServiceProtocol {

    private let database: DatabaseProtocol
    private let authProvider: AuthProvider
    private let logger: LoggerProtocol

    private let favoritesSubject = CurrentValueSubject<Set<String>, Never>([])
    private let favoriteTeamsSubject = CurrentValueSubject<Set<String>, Never>([])

    private var db: Firestore {
        database.db
    }

    private var cancellables = Set<AnyCancellable>()

    init(database: DatabaseProtocol, authProvider: AuthProvider, logger: LoggerProtocol) {
        self.database = database
        self.authProvider = authProvider
        self.logger = logger

        authProvider.observeCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                if user != nil {
                    self.fetchFavorites().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
                    self.fetchFavoriteTeams().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
                } else {
                    self.favoritesSubject.send([])
                    self.favoriteTeamsSubject.send([])
                }
            }
            .store(in: &cancellables)
    }

    private func getUserId() -> String? {
        return authProvider.currentUserId
    }

    // MARK: - Protocol Implementation

    func fetchFavorites() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self, let userId = self.getUserId() else {
                promise(.failure(NSError(domain: "FavoritesService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }
            self.db.collection(FirestoreConstants.Collection.users)
                .document(userId)
                .collection(FirestoreConstants.Collection.favorites)
                .getDocuments { snapshot, error in
                    if let error = error {
                        self.logger.error("Error fetching favorites", error: error)
                        promise(.failure(error))
                        return
                    }
                    let ids = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
                    self.favoritesSubject.send(ids)
                    promise(.success(()))
                }
        }
        .eraseToAnyPublisher()
    }

    func fetchFavoriteTeams() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self, let userId = self.getUserId() else {
                promise(.failure(NSError(domain: "FavoritesService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }
            self.db.collection(FirestoreConstants.Collection.users)
                .document(userId)
                .collection("favoriteTeams")
                .getDocuments { snapshot, error in
                    if let error = error {
                        self.logger.error("Error fetching favorite teams", error: error)
                        promise(.failure(error))
                        return
                    }
                    let ids = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
                    self.favoriteTeamsSubject.send(ids)
                    promise(.success(()))
                }
        }
        .eraseToAnyPublisher()
    }

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
                    favRef.delete { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(false))
                            self.fetchFavorites().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
                        }
                    }
                } else {
                    favRef.setData([
                        "matchId": matchId,
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(true))
                            self.fetchFavorites().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
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

            let normalizedTeamId = teamId.lowercased()

            let favRef = self.db.collection(FirestoreConstants.Collection.users).document(userId).collection("favoriteTeams").document(normalizedTeamId)

            favRef.getDocument { snapshot, error in
                if let error = error {
                    self.logger.error("Error obteniendo documento", error: error)
                    promise(.failure(error))
                    return
                }

                if snapshot?.exists == true {
                    favRef.delete { error in
                        if let error = error {
                            self.logger.error("Error eliminando favorito", error: error)
                            promise(.failure(error))
                        } else {
                            promise(.success(false))
                            self.fetchFavoriteTeams().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
                        }
                    }
                } else {
                    favRef.setData([
                        "teamId": normalizedTeamId,
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            self.logger.error("Error agregando favorito", error: error)
                            promise(.failure(error))
                        } else {
                            promise(.success(true))
                            self.fetchFavoriteTeams().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
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
    
    func getCurrentFavoriteTeams() -> Set<String> {
        return favoriteTeamsSubject.value
    }
}
