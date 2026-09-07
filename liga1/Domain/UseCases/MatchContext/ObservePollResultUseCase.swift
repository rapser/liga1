//
//  ObservePollResultUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol ObservePollResultUseCaseProtocol {
    /// Conteo agregado en vivo + el voto propio (una sola lectura al inicio).
    func execute(pollId: String) -> AnyPublisher<PollResult, Error>
}

final class ObservePollResultUseCase: ObservePollResultUseCaseProtocol {

    private let repository: PollRepositoryProtocol
    private let authService: AuthServiceProtocol

    init(repository: PollRepositoryProtocol, authService: AuthServiceProtocol) {
        self.repository = repository
        self.authService = authService
    }

    func execute(pollId: String) -> AnyPublisher<PollResult, Error> {
        let id = pollId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            return Just(.empty).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let myVote: AnyPublisher<String?, Never>
        if let uid = authService.currentUserId, !uid.isEmpty {
            myVote = repository.fetchMyVote(pollId: id, uid: uid)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        } else {
            myVote = Just(nil).eraseToAnyPublisher()
        }

        return repository.observeTally(pollId: id)
            .combineLatest(myVote.setFailureType(to: Error.self))
            .map { tally, vote in PollResult(tally: tally, myVote: vote) }
            .eraseToAnyPublisher()
    }
}
