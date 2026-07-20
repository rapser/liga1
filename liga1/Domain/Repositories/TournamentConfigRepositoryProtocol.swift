//
//  TournamentConfigRepositoryProtocol.swift
//  liga1
//

import Combine

/// Contrato de dominio para consultar la disponibilidad estacional de tablas.
protocol TournamentConfigRepositoryProtocol {
    /// Último valor activado y persistido localmente por la fuente remota.
    var activeClausuraEnabled: Bool { get }

    /// Consulta y activa el valor remoto vigente, con fallback al valor activo.
    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never>
}
