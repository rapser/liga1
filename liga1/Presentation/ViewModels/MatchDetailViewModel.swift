//
//  MatchDetailViewModel.swift
//  liga1
//

import Foundation

struct MatchDetailContext {
    let jornadaId: String
    let jornadaNumero: Int
    let torneo: String
    let match: MatchUI
}

struct MatchDetailStatRow: Equatable {
    let title: String
    let localDisplay: String
    let visitanteDisplay: String
    /// Magnitud numérica para la barra comparativa (local vs visitante).
    let localMagnitude: Double
    let visitanteMagnitude: Double
    /// Línea secundaria bajo el valor (ej. pases 231/275).
    let localSubtitle: String?
    let visitanteSubtitle: String?

    init(
        title: String,
        localDisplay: String,
        visitanteDisplay: String,
        localMagnitude: Double,
        visitanteMagnitude: Double,
        localSubtitle: String? = nil,
        visitanteSubtitle: String? = nil
    ) {
        self.title = title
        self.localDisplay = localDisplay
        self.visitanteDisplay = visitanteDisplay
        self.localMagnitude = localMagnitude
        self.visitanteMagnitude = visitanteMagnitude
        self.localSubtitle = localSubtitle
        self.visitanteSubtitle = visitanteSubtitle
    }

    init(title: String, local: Int, visitante: Int) {
        self.init(
            title: title,
            localDisplay: "\(local)",
            visitanteDisplay: "\(visitante)",
            localMagnitude: Double(local),
            visitanteMagnitude: Double(visitante),
            localSubtitle: nil,
            visitanteSubtitle: nil
        )
    }

    init(title: String, local: Double, visitante: Double, localDisplay: String, visitanteDisplay: String) {
        self.init(
            title: title,
            localDisplay: localDisplay,
            visitanteDisplay: visitanteDisplay,
            localMagnitude: local,
            visitanteMagnitude: visitante,
            localSubtitle: nil,
            visitanteSubtitle: nil
        )
    }

    /// Goles esperados con formato local (coma decimal, 2 cifras como en vivo).
    static func expectedGoalsRow(local: Double, visitante: Double) -> MatchDetailStatRow {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "es_PE")
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        let ls = nf.string(from: NSNumber(value: local)) ?? String(format: "%.2f", local)
        let vs = nf.string(from: NSNumber(value: visitante)) ?? String(format: "%.2f", visitante)
        return MatchDetailStatRow(
            title: "Goles esperados (xG)",
            local: local,
            visitante: visitante,
            localDisplay: ls,
            visitanteDisplay: vs
        )
    }

    /// Pases: porcentaje principal y fracción completados/intentos debajo.
    static func passesRow(
        localPct: Int,
        localCompleted: Int,
        localAttempts: Int,
        visitPct: Int,
        visitCompleted: Int,
        visitAttempts: Int
    ) -> MatchDetailStatRow {
        MatchDetailStatRow(
            title: "Pases",
            localDisplay: "\(localPct)%",
            visitanteDisplay: "\(visitPct)%",
            localMagnitude: Double(localPct),
            visitanteMagnitude: Double(visitPct),
            localSubtitle: "\(localCompleted)/\(localAttempts)",
            visitanteSubtitle: "\(visitCompleted)/\(visitAttempts)"
        )
    }
}

final class MatchDetailViewModel {

    let context: MatchDetailContext

    init(context: MatchDetailContext) {
        self.context = context
    }

    private var match: MatchUI { context.match }

    var competitionLine: String {
        let torneo = context.torneo.capitalized
        return "PERÚ · LIGA 1 · \(torneo) · JORNADA \(context.jornadaNumero)"
    }

    var localTeamName: String {
        EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoLocalId ?? "")
    }

    var visitTeamName: String {
        EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoVisitanteId ?? "")
    }

    var scoreDisplay: String {
        switch match.estado {
        case .pendiente:
            return "—  :  —"
        default:
            return "\(match.golesEquipoLocal) - \(match.golesEquipoVisitante)"
        }
    }

    var dateTimeLine: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_PE")
        df.dateFormat = "dd.MM.yyyy  hh:mm a"
        return df.string(from: match.fecha)
    }

    var statusLine: String {
        if match.suspendido { return "Suspendido" }
        return match.estadoTexto
    }

    /// Lista completa tipo “estadísticas principales” (dummy, alineada a referencia visual).
    private var estadisticasTabFullDummy: [MatchDetailStatRow] {
        [
            .expectedGoalsRow(local: 0.13, visitante: 0.71),
            MatchDetailStatRow(
                title: "Posesión",
                localDisplay: "53%",
                visitanteDisplay: "47%",
                localMagnitude: 53,
                visitanteMagnitude: 47
            ),
            MatchDetailStatRow(title: "Remates totales", local: 3, visitante: 7),
            MatchDetailStatRow(title: "Remates a puerta", local: 0, visitante: 3),
            MatchDetailStatRow(title: "Grandes ocasiones", local: 0, visitante: 1),
            MatchDetailStatRow(title: "Córneres", local: 1, visitante: 0),
            .passesRow(
                localPct: 84,
                localCompleted: 231,
                localAttempts: 275,
                visitPct: 78,
                visitCompleted: 197,
                visitAttempts: 251
            ),
            MatchDetailStatRow(title: "Tarjetas amarillas", local: 0, visitante: 1),
            MatchDetailStatRow(title: "Tarjetas rojas", local: 1, visitante: 0)
        ]
    }

    /// En Resumen solo las tres primeras métricas (mismos valores que abren la pestaña).
    var resumenStatRows: [MatchDetailStatRow] {
        Array(estadisticasTabFullDummy.prefix(3))
    }

    var estadisticasTabRows: [MatchDetailStatRow] { estadisticasTabFullDummy }

    /// Canal de transmisión fijo para todos los partidos (Liga 1).
    var tvChannels: [String] { ["L1 Max"] }

    func displayOrConfirm(_ value: String?) -> String {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else {
            return "Por confirmar"
        }
        return v
    }

    /// Nombre a mostrar si el documento trae dato; `nil` en jornadas sin campo o vacío.
    var arbitroSiExiste: String? {
        guard let a = match.arbitro else { return nil }
        let t = a.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    var arbitroDisplay: String { displayOrConfirm(match.arbitro) }

    /// Firestore gana si trae dato; si no, catálogo local por equipo local.
    var estadioDisplay: String {
        if let s = nonEmptyString(match.estadio) { return s }
        if let s = TeamVenueCatalog.info(forLocalTeamId: match.equipoLocalId)?.estadio { return s }
        return "Por confirmar"
    }

    var capacidadDisplay: String {
        if let s = nonEmptyString(match.capacidad) { return s }
        if let s = TeamVenueCatalog.info(forLocalTeamId: match.equipoLocalId)?.capacidadTexto { return s }
        return "Por confirmar"
    }

    private func nonEmptyString(_ value: String?) -> String? {
        guard let t = value?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }

    var shareText: String {
        "\(localTeamName) vs \(visitTeamName) · \(scoreDisplay) · \(dateTimeLine)"
    }

    // MARK: - Alineaciones (dummy; `FootballFormation` admite 4-4-2, 3-5-2, etc.)

    var lineupTabModel: MatchLineupTabModel {
        let visitFormation = FootballFormation.parseCode("3-4-2-1")!
        let localFormation = FootballFormation.parseCode("4-2-3-1")!

        let visitPlayers: [LineupPlayerUIData] = [
            LineupPlayerUIData(number: 1, shortName: "Duarte", rating: 6.2),
            LineupPlayerUIData(number: 2, shortName: "Ibarra", rating: 6.4),
            LineupPlayerUIData(number: 4, shortName: "Rodríguez", rating: 6.5),
            LineupPlayerUIData(number: 15, shortName: "Soto", rating: 6.1),
            LineupPlayerUIData(number: 8, shortName: "Fernández", rating: 6.6),
            LineupPlayerUIData(number: 16, shortName: "Castro", rating: 6.3),
            LineupPlayerUIData(number: 21, shortName: "Vera", rating: 6.7),
            LineupPlayerUIData(number: 11, shortName: "López", rating: 7.0),
            LineupPlayerUIData(number: 10, shortName: "Ramírez", rating: 6.8),
            LineupPlayerUIData(number: 7, shortName: "Díaz", rating: 7.1),
            LineupPlayerUIData(number: 9, shortName: "Giménez", rating: 7.2, scoredGoal: true)
        ]

        let localPlayers: [LineupPlayerUIData] = [
            LineupPlayerUIData(number: 12, shortName: "García", rating: 6.5),
            LineupPlayerUIData(number: 3, shortName: "Paredes", rating: 6.4),
            LineupPlayerUIData(number: 5, shortName: "Mendoza", rating: 6.6),
            LineupPlayerUIData(number: 6, shortName: "Torres", rating: 6.2),
            LineupPlayerUIData(number: 14, shortName: "Ríos", rating: 6.3),
            LineupPlayerUIData(number: 18, shortName: "Salas", rating: 6.7),
            LineupPlayerUIData(number: 19, shortName: "Flores", rating: 6.5),
            LineupPlayerUIData(number: 22, shortName: "Hurtado", rating: 6.8),
            LineupPlayerUIData(number: 17, shortName: "Cruz", rating: 7.0),
            LineupPlayerUIData(number: 20, shortName: "Peña", rating: 6.9),
            LineupPlayerUIData(number: 11, shortName: "Reyna", rating: 6.6)
        ]

        return MatchLineupTabModel(
            visitTop: TeamLineupSideModel(
                teamName: visitTeamName,
                formation: visitFormation,
                players: visitPlayers,
                averageRating: 6.4
            )!,
            localBottom: TeamLineupSideModel(
                teamName: localTeamName,
                formation: localFormation,
                players: localPlayers,
                averageRating: 6.7
            )!
        )
    }
}
