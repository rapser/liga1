//
//  ObserveUserPreferencesUseCase.swift
//  liga1
//
//  Created by miguel tomairo on 26/01/26.
//

import Foundation
import Combine

protocol ObserveUserPreferencesUseCaseProtocol {
    func execute() -> AnyPublisher<UserPreferences?, Never>
}

class ObserveUserPreferencesUseCase: ObserveUserPreferencesUseCaseProtocol {

    private let userPreferencesService: UserPreferencesServiceProtocol

    init(userPreferencesService: UserPreferencesServiceProtocol) {
        self.userPreferencesService = userPreferencesService
    }

    func execute() -> AnyPublisher<UserPreferences?, Never> {
        return userPreferencesService.observePreferences()
            .eraseToAnyPublisher()
    }
}
