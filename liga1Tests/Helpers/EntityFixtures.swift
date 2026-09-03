// EntityFixtures.swift
// liga1Tests

import Foundation
@testable import liga1

// MARK: - Date helpers

/// Construye una fecha exacta en la zona horaria de Lima (UTC−5).
func limaDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "America/Lima")!
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = hour
    comps.minute = minute
    return cal.date(from: comps)!
}

// MARK: - Jornada fixtures

extension Jornada {
    static func fixture(
        id: String = "j1",
        torneo: String = "apertura",
        numero: Int = 1,
        mostrar: Bool = true,
        fechaInicio: Date = Date()
    ) -> Jornada {
        Jornada(id: id, torneo: torneo, numero: numero, mostrar: mostrar, fechaInicio: fechaInicio)
    }
}

// MARK: - Match fixtures

extension Match {
    static func fixture(
        id: String = "alianza_u",
        fecha: Date = limaDate(year: 2025, month: 4, day: 5, hour: 15, minute: 0),
        estado: EstadoMatch = .pendiente
    ) -> Match {
        Match(
            id: id,
            equipoLocalId: "alianza",
            equipoVisitanteId: "u",
            fecha: fecha,
            estado: estado
        )
    }
}

// MARK: - Team fixtures

extension Team {
    static func fixture(nombre: String = "Alianza Lima", puntos: Int = 10) -> Team {
        Team(nombre: nombre, ciudad: "Lima", logo: "alianza", puntos: puntos)
    }

    /// Fila de tabla para tests del simulador. `code` es el identificador (`logo`).
    static func standing(
        code: String,
        pts: Int = 0,
        pj: Int = 0,
        pg: Int = 0,
        pe: Int = 0,
        pp: Int = 0,
        gf: Int = 0,
        gc: Int = 0
    ) -> Team {
        Team(
            nombre: code.uppercased(),
            ciudad: "",
            logo: code,
            partidosJugados: pj,
            partidosGanados: pg,
            partidosEmpatados: pe,
            partidosPerdidos: pp,
            golesFavor: gf,
            golesContra: gc,
            diferenciaGoles: gf - gc,
            puntos: pts
        )
    }
}

// MARK: - NewsItem fixtures

extension NewsItem {
    static func fixture(title: String = "Noticia de prueba") -> NewsItem {
        NewsItem(
            title: title,
            imageUrl: "https://example.com/img.jpg",
            url: "https://example.com",
            source: "Test Source",
            category: .destacado,
            publishedDate: Date()
        )
    }
}

// MARK: - UserPreferences fixtures

extension UserPreferences {
    static func fixture(pushEnabled: Bool = true, topics: Set<String> = []) -> UserPreferences {
        UserPreferences(pushNotificationsEnabled: pushEnabled, subscribedTopics: topics)
    }
}

// MARK: - User fixtures

extension User {
    static func fixture(
        id: String = "user-123",
        email: String? = "test@liga1.pe",
        displayName: String? = "Test User"
    ) -> User {
        User(
            id: id,
            email: email,
            displayName: displayName,
            photoURL: nil,
            isEmailVerified: true
        )
    }
}

// MARK: - Test errors

enum TestError: Error, Equatable {
    case generic
    case network
}

// MARK: - RefereePoll fixtures

extension RefereePoll {
    static func fixture(
        id: String = "poll-1",
        matchId: String = "hua_ali",
        jornadaId: String = "clausura_05",
        pregunta: String = "¿Fue penal el reclamo del minuto 63?",
        opciones: [RefereePoll.Option] = [
            .init(id: "si", texto: "Sí, penal"),
            .init(id: "no", texto: "No fue"),
            .init(id: "dudoso", texto: "Dudoso")
        ],
        estado: RefereePoll.Estado = .activa,
        cierraEn: Date = Date().addingTimeInterval(180),
        creadoEn: Date? = Date(),
        numShards: Int = 10
    ) -> RefereePoll {
        RefereePoll(
            id: id, matchId: matchId, jornadaId: jornadaId, pregunta: pregunta,
            opciones: opciones, estado: estado, cierraEn: cierraEn,
            creadoEn: creadoEn, numShards: numShards
        )
    }
}
