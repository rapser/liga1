//
//  FirebaseTournamentConfigRepository.swift
//  liga1
//

import Foundation
import Combine
import FirebaseRemoteConfig

/// Adaptador de Remote Config para la configuración estacional del torneo.
final class FirebaseTournamentConfigRepository: TournamentConfigRepositoryProtocol {

    static let clausuraEnabledKey = "standings_clausura_enabled"

    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 300
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Self.clausuraEnabledKey: false as NSObject
        ])
    }

    var activeClausuraEnabled: Bool {
        currentValue
    }

    func refreshClausuraEnabled() -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { [remoteConfig] promise in
            // Volver a Tabla es una acción explícita: esta lectura omite el
            // caché temporal, pero conserva el valor activo si no hay red.
            remoteConfig.fetch(withExpirationDuration: 0) { status, _ in
                guard status == .success else {
                    promise(.success(Self.value(from: remoteConfig)))
                    return
                }

                remoteConfig.activate { _, _ in
                    promise(.success(Self.value(from: remoteConfig)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private var currentValue: Bool {
        Self.value(from: remoteConfig)
    }

    private static func value(from remoteConfig: RemoteConfig) -> Bool {
        // Prioridad nativa: remoto activado y persistido > default local.
        remoteConfig
            .configValue(forKey: clausuraEnabledKey)
            .boolValue
    }
}
