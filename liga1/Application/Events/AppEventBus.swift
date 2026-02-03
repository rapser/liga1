//
//  AppEventBus.swift
//  liga1
//
//  Implementación del bus de eventos (Combine).
//

import Foundation
import Combine

/// Implementación de AppEventBusProtocol con PassthroughSubject.
final class AppEventBus: AppEventBusProtocol {

    private let subject = PassthroughSubject<AppEvent, Never>()

    func publish(_ event: AppEvent) {
        subject.send(event)
    }

    func events() -> AnyPublisher<AppEvent, Never> {
        return subject.eraseToAnyPublisher()
    }
}
