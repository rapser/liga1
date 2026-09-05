//
//  RefereePoll.swift
//  liga1
//

import Foundation

/// Micro-encuesta arbitral en vivo ("¿fue penal?"). La crea el Admin durante el
/// partido; la app la muestra y permite un voto por usuario. Entidad de dominio pura.
struct RefereePoll {

    struct Option: Equatable {
        let id: String
        let texto: String
    }

    enum Estado: String {
        case activa
        case cerrada
    }

    let id: String
    let matchId: String
    let jornadaId: String
    let pregunta: String
    let opciones: [Option]
    let estado: Estado
    /// Instante en que deja de aceptar votos.
    let cierraEn: Date
    let creadoEn: Date?
    /// Nº de shards del contador distribuido (para elegir uno al azar al votar).
    let numShards: Int

    /// Acepta votos: activa y dentro de ventana.
    func isOpen(now: Date = Date()) -> Bool {
        estado == .activa && cierraEn > now
    }

    func hasOption(_ optionId: String) -> Bool {
        opciones.contains { $0.id == optionId }
    }
}

extension RefereePoll: Equatable {
    static func == (lhs: RefereePoll, rhs: RefereePoll) -> Bool {
        lhs.id == rhs.id &&
            lhs.estado == rhs.estado &&
            lhs.cierraEn == rhs.cierraEn &&
            lhs.opciones == rhs.opciones &&
            lhs.pregunta == rhs.pregunta
    }
}
