//
//  HomeViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import Combine

class HomeViewModel {

    // MARK: - Published Properties

    @Published private(set) var jornadaSections: [JornadaSection] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let getJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol
    private let fetchMatchesUseCase: FetchMatchesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        getJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol,
        fetchMatchesUseCase: FetchMatchesUseCaseProtocol
    ) {
        self.getJornadaToDisplayUseCase = getJornadaToDisplayUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase

        observeJornadaToDisplay()
    }

    // MARK: - Public Methods

    func fetchActiveJornadas(force: Bool = false) {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        getJornadaToDisplayUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] jornada in
                guard let self = self else { return }

                guard self.shouldReloadMatches(for: jornada, force: force) else {
                    self.isLoading = false
                    return
                }

                self.loadMatchesForJornadas(jornada.map { [$0] } ?? [])
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeJornadaToDisplay() {
        getJornadaToDisplayUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] jornada in
                self?.loadMatchesForJornadas(jornada.map { [$0] } ?? [])
            }
            .store(in: &cancellables)
    }

    private func shouldReloadMatches(for jornada: Jornada?, force: Bool) -> Bool {
        if force { return true }

        let currentJornadaId = jornadaSections.first?.jornadaId
        let incomingJornadaId = jornada?.id

        switch (incomingJornadaId, currentJornadaId) {
        case let (newId?, currentId?):
            return newId != currentId
        case (nil, nil):
            return false
        default:
            return true
        }
    }

    private func loadMatchesForJornadas(_ jornadas: [Jornada]) {
        guard !jornadas.isEmpty else {
            jornadaSections = []
            return
        }

        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            return fetchMatchesUseCase.execute(for: jornada.id)
                .map { matches in
                    return (jornada, matches)
                }
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] results in
                self?.processJornadasWithMatches(results)
            }
            .store(in: &cancellables)
    }

    private func processJornadasWithMatches(_ results: [(Jornada, [Match])]) {
        var tempSections: [JornadaSection] = []

        for (jornada, matches) in results {
            let matchUIs = MatchUIMapper.toUI(from: matches)

            let section = JornadaSection(
                jornadaId: jornada.id,
                numero: jornada.numero,
                torneo: jornada.torneo,
                matches: matchUIs
            )
            tempSections.append(section)
        }

        jornadaSections = tempSections.sorted { $0.numero < $1.numero }
    }
}
