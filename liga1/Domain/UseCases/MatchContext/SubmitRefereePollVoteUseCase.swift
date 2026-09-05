//
//  SubmitRefereePollVoteUseCase.swift
//  liga1
//

import Foundation
import Combine

enum RefereePollVoteError: LocalizedError, Equatable {
    case notSignedIn
    case pollClosed
    case unknownOption

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Inicia sesión para votar."
        case .pollClosed: return "La encuesta ya cerró."
        case .unknownOption: return "Opción no válida."
        }
    }
}

protocol SubmitRefereePollVoteUseCaseProtocol {
    /// Registra el voto del usuario actual. Devuelve el `optionId` votado.
    func execute(poll: RefereePoll, optionId: String) -> AnyPublisher<String, Error>
}

final class SubmitRefereePollVoteUseCase: SubmitRefereePollVoteUseCaseProtocol {

    private let repository: PollRepositoryProtocol
    private let authService: AuthServiceProtocol

    init(repository: PollRepositoryProtocol, authService: AuthServiceProtocol) {
        self.repository = repository
        self.authService = authService
    }

    func execute(poll: RefereePoll, optionId: String) -> AnyPublisher<String, Error> {
        let option = optionId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let uid = authService.currentUserId, !uid.isEmpty else {
            return Fail(error: RefereePollVoteError.notSignedIn).eraseToAnyPublisher()
        }
        guard poll.hasOption(option) else {
            return Fail(error: RefereePollVoteError.unknownOption).eraseToAnyPublisher()
        }
        guard poll.isOpen() else {
            return Fail(error: RefereePollVoteError.pollClosed).eraseToAnyPublisher()
        }

        return repository
            .vote(pollId: poll.id, optionId: option, uid: uid, numShards: poll.numShards)
            .map { option }
            .eraseToAnyPublisher()
    }
}
