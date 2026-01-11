//
//  FirestoreConstants.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation

/// Constantes centralizadas para colecciones y campos de Firestore
/// Elimina magic strings hardcodeados en todo el proyecto
public enum FirestoreConstants {

    // MARK: - Collections

    public enum Collection {
        public static let jornadas = "jornadas"
        public static let matches = "matches"
        public static let users = "users"
        public static let favorites = "favoritos"
        public static let news = "news"
        public static let teams = "equipos"

        // Tournaments
        public static let apertura = "apertura"
        public static let clausura = "clausura"
        public static let acumulado = "acumulado"
    }

    // MARK: - Match Fields

    public enum MatchField {
        public static let id = "id"
        public static let equipoLocalId = "equipoLocalId"
        public static let equipoVisitanteId = "equipoVisitanteId"
        public static let fecha = "fecha"
        public static let golesTeamA = "golesTeamA"
        public static let golesTeamB = "golesTeamB"
        public static let estado = "estado"
        public static let suspendido = "suspendido"
    }

    // MARK: - Match States

    public enum MatchState {
        public static let pending = "pendiente"
        public static let playing = "envivo"
        public static let finished = "finalizado"
        public static let cancelled = "anulado"
        public static let suspended = "suspendido"
    }

    // MARK: - Team Fields

    public enum TeamField {
        public static let name = "name"
        public static let city = "city"
        public static let stadium = "stadium"
        public static let matchesPlayed = "matchesPlayed"
        public static let matchesWon = "matchesWon"
        public static let matchesDrawn = "matchesDrawn"
        public static let matchesLost = "matchesLost"
        public static let goalsScored = "goalsScored"
        public static let goalsAgainst = "goalsAgainst"
        public static let goalDifference = "goalDifference"
        public static let points = "points"
    }

    // MARK: - Jornada Fields

    public enum JornadaField {
        public static let mostrar = "mostrar"
        public static let numero = "numero"
        public static let torneo = "torneo"
        public static let fechaInicio = "fechaInicio"
    }

    // MARK: - News Fields

    public enum NewsField {
        public static let titulo = "titulo"
        public static let descripcion = "descripcion"
        public static let imageUrl = "imageUrl"
        public static let fecha = "fecha"
        public static let destacado = "destacado"
    }
}
