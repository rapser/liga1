//
//  FirestoreConstants.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Constantes centralizadas para colecciones y campos de Firestore
/// Elimina magic strings hardcodeados en todo el proyecto
enum FirestoreConstants {

    // MARK: - Collections

    enum Collection {
        static let jornadas = "jornadas"
        static let matches = "matches"
        static let users = "users"
        static let favorites = "favoritos"
        static let news = "noticias"
        static let teams = "equipos"

        // Tournaments
        static let apertura = "apertura"
        static let clausura = "clausura"
        static let acumulado = "acumulado"
    }

    // MARK: - Match Fields

    enum MatchField {
        static let id = "id"
        static let equipoLocalId = "equipoLocalId"
        static let equipoVisitanteId = "equipoVisitanteId"
        static let fecha = "fecha"
        static let golesTeamA = "golesTeamA"
        static let golesTeamB = "golesTeamB"
        static let estado = "estado"
        static let suspendido = "suspendido"
    }

    // MARK: - Match States

    enum MatchState {
        static let pending = "pendiente"
        static let playing = "enJuego"
        static let finished = "finalizado"
        static let cancelled = "anulado"
        static let suspended = "suspendido"
    }

    // MARK: - Team Fields

    enum TeamField {
        static let name = "name"
        static let city = "city"
        static let stadium = "stadium"
        static let matchesPlayed = "matchesPlayed"
        static let matchesWon = "matchesWon"
        static let matchesDrawn = "matchesDrawn"
        static let matchesLost = "matchesLost"
        static let goalsScored = "goalsScored"
        static let goalsAgainst = "goalsAgainst"
        static let goalDifference = "goalDifference"
        static let points = "points"
    }

    // MARK: - Jornada Fields

    enum JornadaField {
        static let mostrar = "mostrar"
        static let numero = "numero"
        static let torneo = "torneo"
        static let fechaInicio = "fechaInicio"
    }

    // MARK: - News Fields

    enum NewsField {
        static let titulo = "titulo"
        static let descripcion = "descripcion"
        static let imageUrl = "imageUrl"
        static let fecha = "fecha"
        static let destacado = "destacado"
    }
}
