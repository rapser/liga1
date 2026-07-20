//
//  InactivityManager.swift
//  liga1
//
//  Application: Detecta inactividad del usuario y publica .sessionExpired al EventBus.
//  SRP: solo maneja el timer — auth y navegación quedan en AppCoordinator.
//

import Foundation

final class InactivityManager {

    private let eventBus: AppEventBusProtocol
    private let timeout: TimeInterval
    private var timer: Timer?

    init(eventBus: AppEventBusProtocol, timeout: TimeInterval = 432_000) {
        self.eventBus = eventBus
        self.timeout = timeout
    }

    func reset() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.eventBus.publish(.sessionExpired)
        }
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
