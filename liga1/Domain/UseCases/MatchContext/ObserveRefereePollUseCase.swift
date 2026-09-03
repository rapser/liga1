//
//  ObserveRefereePollUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol ObserveRefereePollUseCaseProtocol {
    /// Encuesta arbitral abierta del partido, en tiempo real. `nil` si no hay ninguna.
    func execute(matchId: String) -> AnyPublisher<RefereePoll?, Error>
}

final class ObserveRefereePollUseCase: ObserveRefereePollUseCaseProtocol {

    private let repository: PollRepositoryProtocol

    init(repository: PollRepositoryProtocol) {
        self.repository = repository
    }

    func execute(matchId: String) -> AnyPublisher<RefereePoll?, Error> {
        let id = matchId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return repository.observeActivePoll(matchId: id)
    }
}
