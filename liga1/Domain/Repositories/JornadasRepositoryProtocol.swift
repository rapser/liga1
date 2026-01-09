//
//  JornadasRepositoryProtocol.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation
import Combine

/// Protocolo para obtener jornadas activas
protocol JornadasRepositoryProtocol {
    func fetchActiveJornadas() -> AnyPublisher<[Jornada], Error>
}
