//
//  AppEvent.swift
//  liga1
//
//  Eventos tipados de la app (EventBus).
//

import Foundation

/// Eventos de aplicación para el bus (logout, sesión, navegación).
/// Nota: loginSuccess fue eliminado — AppCoordinator observa AuthServiceProtocol directamente.
enum AppEvent {
    case logoutRequested
    case sessionExpired
    case navigateToMatch(MatchRoute)
}

/// Destino de una notificación de partido (gol, inicio, final): abre su detalle.
struct MatchRoute: Equatable {
    let matchId: String
    /// Formato "torneo_numero", ej. "clausura_15".
    let jornadaId: String

    var torneo: String {
        jornadaId.split(separator: "_").first.map(String.init) ?? ""
    }

    var jornadaNumero: Int {
        jornadaId.split(separator: "_").dropFirst().first.flatMap { Int($0) } ?? 0
    }

    init(matchId: String, jornadaId: String) {
        self.matchId = matchId
        self.jornadaId = jornadaId
    }

    /// Lee el payload de FCM. Las notificaciones visibles del live-sync usan
    /// `match_id`/`jornada_id`; el push silencioso usa `matchId`/`jornadaId`.
    init?(userInfo: [AnyHashable: Any]) {
        func value(_ keys: String...) -> String? {
            keys.lazy.compactMap { userInfo[$0] as? String }.first { !$0.isEmpty }
        }
        guard let matchId = value("match_id", FirestoreConstants.PushPayload.matchId),
              let jornadaId = value("jornada_id", FirestoreConstants.PushPayload.jornadaId) else {
            return nil
        }
        self.init(matchId: matchId, jornadaId: jornadaId)
    }
}
