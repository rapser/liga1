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

    var arbitroDisplay: String { displayOrConfirm(match.arbitro) }
    var estadioDisplay: String { displayOrConfirm(match.estadio) }
    var capacidadDisplay: String { displayOrConfirm(match.capacidad) }

    var shareText: String {
        "\(localTeamName) vs \(visitTeamName) · \(scoreDisplay) · \(dateTimeLine)"
    }
}
