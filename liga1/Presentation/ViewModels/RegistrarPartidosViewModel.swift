//
//  RegistrarPartidosViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
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
    private let logger: LoggerProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(registerMatchesUseCase: RegisterMatchesUseCaseProtocol, logger: LoggerProtocol) {
        self.registerMatchesUseCase = registerMatchesUseCase
        self.logger = logger
    }

    // MARK: - Public Methods

    /// Registra una jornada individual
    func registerJornada(numero: Int) {
        isLoading = true
        error = nil
        successMessage = nil
        
        let jornadaId = String(format: "apertura_%02d", numero)
        let fechaBase = AperturaFixtureData.fechaBase
        let matches = AperturaFixtureData.crearMatchesParaJornada(numero, fecha: fechaBase)
        
        registerMatchesUseCase.registerJornadaWithMatches(
            jornadaId: jornadaId,
            mostrar: false,
            fechaInicio: fechaBase,
            matches: matches
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.logger.error("Failed to register jornada \(jornadaId)", error: error)
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.successMessage = "Jornada \(numero) registrada exitosamente con \(matches.count) partidos"
        }
        .store(in: &cancellables)
    }

    /// Registra todas las jornadas del Torneo Apertura
    func registerAllAperturaJornadas() {
        isLoading = true
        error = nil
        successMessage = nil
        
        registerMatchesUseCase.registerAllAperturaJornadas()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.logger.error("Failed to register all Apertura jornadas", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.successMessage = "Todas las 17 jornadas del Torneo Apertura registradas exitosamente"
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
