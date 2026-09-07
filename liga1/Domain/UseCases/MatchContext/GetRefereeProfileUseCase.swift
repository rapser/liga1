//
//  GetRefereeProfileUseCase.swift
//  liga1
//

import Foundation
import Combine

protocol GetRefereeProfileUseCaseProtocol {
    /// Ficha del árbitro a partir de su nombre libre (campo `arbitro` del partido).
    /// El id se deriva con `Slug.make` para casar con `referees/{id}`.
    func execute(refereeName: String) -> AnyPublisher<RefereeProfile?, Error>
}

final class GetRefereeProfileUseCase: GetRefereeProfileUseCaseProtocol {

    private let repository: RefereeRepositoryProtocol

    init(repository: RefereeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(refereeName: String) -> AnyPublisher<RefereeProfile?, Error> {
        let id = Slug.make(refereeName)
        guard !id.isEmpty else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return repository.fetchReferee(id: id)
    }
}
