//
//  UserPreferencesService.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol UserPreferencesServiceProtocol {
    func getUserPreferences() -> AnyPublisher<UserPreferences?, Error>
    func updatePushNotificationsEnabled(_ enabled: Bool) -> AnyPublisher<Void, Error>
    func addSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error>
    func removeSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error>
    func setSubscribedTopics(_ topics: Set<String>) -> AnyPublisher<Void, Error>
    func observePreferences() -> AnyPublisher<UserPreferences?, Never>
}

class UserPreferencesService: UserPreferencesServiceProtocol {

    private let database: DatabaseProtocol
    private let authProvider: AuthProvider
    private let authRepository: AuthRepository
    private let logger: LoggerProtocol
    private let preferencesSubject = CurrentValueSubject<UserPreferences?, Never>(nil)

    private var db: Firestore {
        database.db
    }

    private var cancellables = Set<AnyCancellable>()

    init(database: DatabaseProtocol, authProvider: AuthProvider, authRepository: AuthRepository, logger: LoggerProtocol) {
        self.database = database
        self.authProvider = authProvider
        self.authRepository = authRepository
        self.logger = logger

        authRepository.observeAuthState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    self?.fetchPreferencesAndNotify()
                } else {
                    self?.preferencesSubject.send(nil)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Helpers

    private func getUserId() -> String? {
        return authProvider.currentUserId
    }

    private func getPreferencesDocumentRef() -> DocumentReference? {
        guard let userId = getUserId() else { return nil }
        return db.collection(FirestoreConstants.Collection.users)
            .document(userId)
            .collection(FirestoreConstants.Collection.preferences)
            .document(FirestoreConstants.PreferencesDocument.notifications)
    }

    private func fetchPreferencesAndNotify() {
        guard let docRef = getPreferencesDocumentRef() else { return }
        docRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.logger.error("Error fetching user preferences", error: error)
                return
            }
            guard let data = snapshot?.data() else {
                self?.preferencesSubject.send(UserPreferences())
                return
            }
            do {
                let dto = try Firestore.Decoder().decode(UserPreferencesDTO.self, from: data)
                let preferences = UserPreferencesMapper.toDomain(from: dto)
                self?.preferencesSubject.send(preferences)
            } catch {
                self?.logger.error("Error decoding user preferences", error: error)
                self?.preferencesSubject.send(UserPreferences())
            }
        }
    }

    // MARK: - UserPreferencesServiceProtocol

    func getUserPreferences() -> AnyPublisher<UserPreferences?, Error> {
        return Future { [weak self] promise in
            guard let self = self,
                  let docRef = self.getPreferencesDocumentRef() else {
                promise(.failure(NSError(domain: "UserPreferencesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            docRef.getDocument { snapshot, error in
                if let error = error {
                    self.logger.error("Error fetching user preferences", error: error)
                    promise(.failure(error))
                    return
                }

                guard let data = snapshot?.data() else {
                    promise(.success(UserPreferences()))
                    return
                }

                do {
                    let dto = try Firestore.Decoder().decode(UserPreferencesDTO.self, from: data)
                    let preferences = UserPreferencesMapper.toDomain(from: dto)
                    promise(.success(preferences))
                } catch {
                    self.logger.error("Error decoding preferences", error: error)
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func updatePushNotificationsEnabled(_ enabled: Bool) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self,
                  let docRef = self.getPreferencesDocumentRef() else {
                promise(.failure(NSError(domain: "UserPreferencesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            docRef.setData([
                FirestoreConstants.PreferencesField.pushNotificationsEnabled: enabled,
                FirestoreConstants.PreferencesField.updatedAt: FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    self.logger.error("Error updating push notifications enabled", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                    self.fetchPreferencesAndNotify()
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func addSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self,
                  let docRef = self.getPreferencesDocumentRef() else {
                promise(.failure(NSError(domain: "UserPreferencesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            docRef.updateData([
                FirestoreConstants.PreferencesField.subscribedTopics: FieldValue.arrayUnion([topic]),
                FirestoreConstants.PreferencesField.updatedAt: FieldValue.serverTimestamp()
            ]) { error in
                if error != nil {
                    docRef.setData([
                        FirestoreConstants.PreferencesField.pushNotificationsEnabled: true,
                        FirestoreConstants.PreferencesField.subscribedTopics: [topic],
                        FirestoreConstants.PreferencesField.updatedAt: FieldValue.serverTimestamp()
                    ]) { setError in
                        if let setError = setError {
                            self.logger.error("Error creating preferences with topic", error: setError)
                            promise(.failure(setError))
                        } else {
                            promise(.success(()))
                            self.fetchPreferencesAndNotify()
                        }
                    }
                } else {
                    promise(.success(()))
                    self.fetchPreferencesAndNotify()
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func removeSubscribedTopic(_ topic: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self,
                  let docRef = self.getPreferencesDocumentRef() else {
                promise(.failure(NSError(domain: "UserPreferencesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            docRef.updateData([
                FirestoreConstants.PreferencesField.subscribedTopics: FieldValue.arrayRemove([topic]),
                FirestoreConstants.PreferencesField.updatedAt: FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    self.logger.error("Error removing topic", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                    self.fetchPreferencesAndNotify()
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func setSubscribedTopics(_ topics: Set<String>) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self,
                  let docRef = self.getPreferencesDocumentRef() else {
                promise(.failure(NSError(domain: "UserPreferencesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
                return
            }

            docRef.setData([
                FirestoreConstants.PreferencesField.subscribedTopics: Array(topics),
                FirestoreConstants.PreferencesField.updatedAt: FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    self.logger.error("Error setting subscribed topics", error: error)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                    self.fetchPreferencesAndNotify()
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func observePreferences() -> AnyPublisher<UserPreferences?, Never> {
        return preferencesSubject.eraseToAnyPublisher()
    }
}
