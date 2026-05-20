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
    func getCurrentFavoriteTeams() -> Set<String>
    func toggleFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Error>
    func fetchFavoriteTeams() -> AnyPublisher<Void, Error>
    func isFavoriteTeam(teamId: String) -> AnyPublisher<Bool, Never>
    func getAllFavoriteTeams() -> AnyPublisher<[String], Never>
    func observeFavoriteTeams() -> AnyPublisher<Set<String>, Never>
}

class FavoritesService: FavoritesServiceProtocol {

    private let database: DatabaseProtocol
    private let logger: LoggerProtocol

    private let favoriteTeamsSubject = CurrentValueSubject<Set<String>, Never>([])

    private var db: Firestore {
        database.db
    }

    private var cancellables = Set<AnyCancellable>()

    init(database: DatabaseProtocol, logger: LoggerProtocol) {
        self.database = database
        self.logger = logger

        AuthManager.shared.observeAuthState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                if user != nil {
                    self.fetchFavoriteTeams().sink { _ in } receiveValue: { }.store(in: &self.cancellables)
                } else {
                    self.favoriteTeamsSubject.send([])
                }
            }
            .store(in: &cancellables)
    }

    private func getUserId() -> String? {
        return AuthManager.shared.currentUserId
    }

    func fetchFavoriteTeams() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self, let userId = self.getUserId() else {
                promise(.failure(NSError(domain: "FavoritesService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            let ref = self.db
                .collection(FirestoreConstants.Collection.users)
                .document(userId)
                .collection("favoriteTeams")

            // Caché primero: resolve inmediato si hay datos locales, luego
            // refresca en background para que la próxima visita también sea rápida.
            ref.getDocuments(source: .cache) { [weak self] cacheSnapshot, cacheError in
                guard let self = self else { return }

                if cacheError == nil, let docs = cacheSnapshot?.documents {
                    let ids = Set(docs.compactMap { $0.documentID })
                    self.favoriteTeamsSubject.send(ids)
                    promise(.success(()))

                    ref.getDocuments(source: .server) { [weak self] serverSnapshot, _ in
                        guard let self = self, let docs = serverSnapshot?.documents else { return }
                        let serverIds = Set(docs.compactMap { $0.documentID })
                        if serverIds != ids { self.favoriteTeamsSubject.send(serverIds) }
                    }
                } else {
                    // Sin caché (primera carga), ir al servidor directamente.
                    ref.getDocuments(source: .server) { [weak self] snapshot, error in
                        guard let self = self else { return }
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
            }
        }
        .eraseToAnyPublisher()
    }

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
