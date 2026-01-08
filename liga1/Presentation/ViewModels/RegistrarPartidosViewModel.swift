//
//  RegistrarPartidosViewModel.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import Foundation
import Combine

class RegistrarPartidosViewModel {

    // MARK: - Published Properties

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var successMessage: String?

    // MARK: - Private Properties

    private let registerMatchesUseCase: RegisterMatchesUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(registerMatchesUseCase: RegisterMatchesUseCaseProtocol) {
        self.registerMatchesUseCase = registerMatchesUseCase
    }

    // MARK: - Public Methods

    /// Registra un solo partido
    func registerMatch(match: Match, jornadaId: String) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.registerMatch(match: match, jornadaId: jornadaId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to register match", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.successMessage = "Partido registrado exitosamente"
            }
            .store(in: &cancellables)
    }

    /// Registra múltiples partidos
    func registerMultipleMatches(matches: [Match], jornadaId: String) {
        guard !matches.isEmpty else {
            Logger.shared.warning("Attempted to register empty matches array")
            return
        }

        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.registerMultipleMatches(matches: matches, jornadaId: jornadaId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to register multiple matches", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.successMessage = "\(matches.count) partidos registrados exitosamente"
            }
            .store(in: &cancellables)
    }

    /// Actualiza un partido en vivo
    func updateLiveMatch(matchId: String, jornadaId: String, localScore: Int, visitorScore: Int) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.updateLiveMatch(
            matchId: matchId,
            jornadaId: jornadaId,
            localScore: localScore,
            visitorScore: visitorScore
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                Logger.shared.error("Failed to update live match", error: error)
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.successMessage = "Partido actualizado exitosamente"
        }
        .store(in: &cancellables)
    }

    /// Finaliza un partido
    func finalizeMatch(matchId: String, jornadaId: String) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.finalizeMatch(
            matchId: matchId,
            jornadaId: jornadaId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                Logger.shared.error("Failed to finalize match", error: error)
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.successMessage = "Partido finalizado exitosamente"
        }
        .store(in: &cancellables)
    }

    /// Resetea el mensaje de éxito
    func clearSuccessMessage() {
        successMessage = nil
    }

    /// Resetea el error
    func clearError() {
        error = nil
    }
}
