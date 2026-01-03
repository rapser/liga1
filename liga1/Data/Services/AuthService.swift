//
//  AuthService.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService: AuthServiceProtocol {

    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func getCurrentUser() -> AnyPublisher<User?, Never> {
        return Just(Auth.auth().currentUser)
            .eraseToAnyPublisher()
    }
}
