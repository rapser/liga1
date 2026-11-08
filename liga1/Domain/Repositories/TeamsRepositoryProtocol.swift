//
//  TeamsRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener equipos
protocol TeamsRepositoryProtocol {
    /// Lectura puntual de la tabla. `.acumulado` lee la colección `acumulado`,
    /// que el admin mantiene con apertura + clausura + sanciones.
    func fetchTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Error>
    /// Tabla en tiempo real: emite primero desde la caché persistente de Firestore
    /// y luego cada cambio del servidor (p. ej. al finalizar un partido).
    func observeTeams(for torneo: TorneoType) -> AnyPublisher<[Team], Never>
    /// Lee las tablas indicadas desde el servidor para dejarlas en la caché persistente.
    /// Lo usa el push silencioso en background: al volver, la tabla ya sale actualizada.
    /// `completion(true)` si todas las lecturas terminaron bien.
    func refreshStandings(for torneos: [TorneoType], completion: @escaping (Bool) -> Void)
    /// Sanciones en tiempo real (`equipos/{code}.sanctions`). Si falla, emite `[]`.
    func observePointSanctions() -> AnyPublisher<[PointSanction], Never>
    /// Invalida la caché en memoria para el torneo indicado (nil = todos).
    func invalidateCache(for torneo: TorneoType?)
}
