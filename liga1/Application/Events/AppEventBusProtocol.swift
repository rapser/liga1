//
//  AppEventBusProtocol.swift
//  liga1
//
//  Protocolo del bus de eventos de la app.
//

import Foundation
import Combine

/// Bus de eventos de la app. Publicar desde ViewModels/VCs; suscribirse en Coordinators.
protocol AppEventBusProtocol {
    func publish(_ event: AppEvent)
    func events() -> AnyPublisher<AppEvent, Never>
}
