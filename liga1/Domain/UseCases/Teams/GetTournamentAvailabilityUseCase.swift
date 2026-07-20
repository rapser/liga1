//
//  GetTournamentAvailabilityUseCase.swift
//  liga1
//

import Combine

protocol GetTournamentAvailabilityUseCaseProtocol {
    var activeClausuraEnabled: Bool { get }
    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never>
}

/// Expone al ViewModel la configuración estacional sin acoplarlo a Firebase.
final class GetTournamentAvailabilityUseCase: GetTournamentAvailabilityUseCaseProtocol {

    private let repository: TournamentConfigRepositoryProtocol

    init(repository: TournamentConfigRepositoryProtocol) {
        self.repository = repository
    }

    var activeClausuraEnabled: Bool {
        repository.activeClausuraEnabled
    }

    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never> {
        repository.refreshClausuraEnabled()
    }
}
