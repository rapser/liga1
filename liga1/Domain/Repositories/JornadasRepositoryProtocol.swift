//
//  JornadasRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

protocol JornadasRepositoryProtocol {
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
    func observeActiveJornadas() -> AnyPublisher<[Jornada], Never>
    /// Todas las jornadas del calendario (sin filtrar por `mostrar`). Para el simulador.
    func fetchAllJornadas() -> AnyPublisher<[Jornada], Error>
}
