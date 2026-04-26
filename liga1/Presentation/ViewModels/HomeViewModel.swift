//
//  HomeViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import Foundation
import Combine

extension HomeViewModel {
    /// Cómo filtrar partidos en Inicio (estilo calendario por día, p. ej. Flashscore).
    enum MatchDayMode: Equatable {
        /// Hoy en Perú (UTC−5); puede quedar vacío si no hay partidos. Se recalcula en cada carga.
        case today
        /// Día elegido en el calendario (siempre interpretado en hora Perú).
        case specificDay(Date)
    }
}

class HomeViewModel {

    // MARK: - Published Properties

    @Published private(set) var jornadaSections: [JornadaSection] = []
    /// `true` al crear el VM evita mostrar el placeholder vacío un instante antes de la primera carga.
    @Published private(set) var isLoading: Bool = true
    /// Solo `true` tras al menos un ciclo de carga conocido; evita el placeholder si `observe` emite `[]` antes del fetch explícito.
    @Published private(set) var canShowNoMatchesPlaceholder: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var matchDayMode: MatchDayMode = .today

    // MARK: - Dependencies

    private let getJornadaToDisplayUseCase: GetJornadaToDisplayUseCaseProtocol
    private let fetchMatchesUseCase: FetchMatchesUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var fetchJornadaCancellable: AnyCancellable?
    private var loadMatchesCancellable: AnyCancellable?
    /// Evita aplicar resultados de cargas obsoletas si el usuario refresca seguido o cambia de fecha.
    private var loadGeneration: Int = 0
    private var hasReceivedFetchJornadasResponse = false

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

    func setMatchDayMode(_ mode: MatchDayMode) {
        switch mode {
        case .today:
            matchDayMode = .today
        case .specificDay(let d):
            let norm = Self.limaStartOfDay(d)
            let today = Self.limaStartOfDay(Date())
            matchDayMode = (norm == today) ? .today : .specificDay(norm)
        }
        fetchActiveJornadas(force: true)
    }

    func fetchActiveJornadas(force: Bool = false) {
        fetchJornadaCancellable?.cancel()
        /// No incrementar `loadGeneration` ni cancelar `loadMatches` aquí: si `observe()` emite
        /// antes del `receiveValue` del fetch, la guarda antigua hacía que el fetch no cargara partidos
        /// y el listado quedaba vacío hasta volver a disparar (p. ej. abriendo el calendario).

        isLoading = true
        error = nil

        fetchJornadaCancellable = getJornadaToDisplayUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let err) = completion {
                    self.error = err
                    self.hasReceivedFetchJornadasResponse = true
                    self.isLoading = false
                    self.canShowNoMatchesPlaceholder = true
                }
            } receiveValue: { [weak self] jornadas in
                guard let self else { return }
                self.hasReceivedFetchJornadasResponse = true

                guard self.shouldReloadMatches(for: jornadas, force: force) else {
                    self.isLoading = false
                    self.canShowNoMatchesPlaceholder = true
                    return
                }

                self.loadMatchesCancellable?.cancel()
                self.loadGeneration += 1
                let generation = self.loadGeneration
                self.loadMatchesForJornadas(jornadas, generation: generation, fromObserve: false)
            }
    }

    // MARK: - Private Methods

    private func observeJornadaToDisplay() {
        getJornadaToDisplayUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] jornadas in
                guard let self else { return }
                self.loadMatchesCancellable?.cancel()
                self.loadGeneration += 1
                let generation = self.loadGeneration
                self.loadMatchesForJornadas(jornadas, generation: generation, fromObserve: true)
            }
            .store(in: &cancellables)
    }

    private func shouldReloadMatches(for jornadas: [Jornada], force: Bool) -> Bool {
        if force { return true }

        let incoming = Set(jornadas.map(\.id))
        let current = Set(jornadaSections.map(\.jornadaId))
        return incoming != current
    }

    private func loadMatchesForJornadas(_ jornadas: [Jornada], generation: Int, fromObserve: Bool) {
        loadMatchesCancellable?.cancel()

        guard !jornadas.isEmpty else {
            if generation == loadGeneration {
                jornadaSections = []
            }
            let shouldRevealEmptyState = !fromObserve || hasReceivedFetchJornadasResponse
            if shouldRevealEmptyState {
                isLoading = false
                canShowNoMatchesPlaceholder = true
            }
            return
        }

        let day = calendarDayForFetch()
        let publishers = jornadas.map { jornada -> AnyPublisher<(Jornada, [Match]), Error> in
            fetchMatchesUseCase.execute(for: jornada.id, calendarDay: day)
                .map { matches in (jornada, matches) }
                .eraseToAnyPublisher()
        }

        loadMatchesCancellable = Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                guard generation == self.loadGeneration else { return }
                if case .failure(let err) = completion {
                    self.error = err
                }
                self.isLoading = false
                self.canShowNoMatchesPlaceholder = true
            } receiveValue: { [weak self] results in
                guard let self else { return }
                guard generation == self.loadGeneration else { return }
                self.processJornadasWithMatches(results)
                self.canShowNoMatchesPlaceholder = true
            }
    }

    private static func limaStartOfDay(_ date: Date) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Lima") ?? .current
        return cal.startOfDay(for: date)
    }

    private func calendarDayForFetch() -> Date {
        switch matchDayMode {
        case .today:
            return Self.limaStartOfDay(Date())
        case .specificDay(let d):
            return d
        }
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

        jornadaSections = tempSections
            .sorted { $0.numero < $1.numero }
            .filter { !$0.matches.isEmpty }
    }
}
