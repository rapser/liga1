//
//  TeamDetailViewModel.swift
//  liga1
//

import Foundation
import Combine

final class TeamDetailViewModel {

    /// Jugadores de una misma línea, en el orden de la plantilla.
    struct SquadSection: Equatable {
        let position: PlayerPosition
        let players: [Player]
    }

    enum State: Equatable {
        case loading
        case loaded([SquadSection])
        case empty
        case failed(String)
    }

    // MARK: - Published Properties

    @Published private(set) var state: State = .loading

    // MARK: - Properties

    let team: TeamUI
    /// Atribución de las fotos mostradas (p. ej. "Wikimedia Commons"), si alguna la exige.
    private(set) var photoCredit: String?

    // MARK: - Dependencies

    private let fetchSquadUseCase: FetchSquadUseCaseProtocol
    private var cancellable: AnyCancellable?

    // MARK: - Initialization

    init(team: TeamUI, fetchSquadUseCase: FetchSquadUseCaseProtocol) {
        self.team = team
        self.fetchSquadUseCase = fetchSquadUseCase
    }

    // MARK: - Public Methods

    /// `TeamUI.logo` es el código del equipo ("ali", "uni"...), el mismo id de `equipos/{code}`.
    func load() {
        state = .loading
        cancellable = fetchSquadUseCase.execute(teamId: team.logo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.state = .failed("No pudimos cargar la plantilla. Revisa tu conexión e inténtalo de nuevo.")
                }
            } receiveValue: { [weak self] players in
                self?.apply(players)
            }
    }

    // MARK: - Private Methods

    private func apply(_ players: [Player]) {
        guard !players.isEmpty else {
            photoCredit = nil
            state = .empty
            return
        }

        photoCredit = Set(players.compactMap { $0.photoURL == nil ? nil : $0.photoCredit })
            .sorted()
            .joined(separator: ", ")
            .nilIfEmpty

        let sections = PlayerPosition.allCases.compactMap { position -> SquadSection? in
            let inPosition = players.filter { $0.position == position }
            return inPosition.isEmpty ? nil : SquadSection(position: position, players: inPosition)
        }
        state = .loaded(sections)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
