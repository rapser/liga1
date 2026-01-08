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
    func registerMatch(partido: Partido) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.registerMatch(partido: partido)
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
    func registerMultipleMatches(partidos: [Partido]) {
        guard !partidos.isEmpty else {
            Logger.shared.warning("Attempted to register empty matches array")
            return
        }

        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.registerMultipleMatches(partidos: partidos)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to register multiple matches", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.successMessage = "\(partidos.count) partidos registrados exitosamente"
            }
            .store(in: &cancellables)
    }

    /// Actualiza un partido en vivo
    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.updateLiveMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha,
            teamAScore: teamAScore,
            teamBScore: teamBScore
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
    func finalizeMatch(teamAId: String, teamBId: String, fecha: String) {
        isLoading = true
        error = nil
        successMessage = nil

        registerMatchesUseCase.finalizeMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            fecha: fecha
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
