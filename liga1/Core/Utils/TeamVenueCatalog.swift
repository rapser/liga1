//
//  TeamVenueCatalog.swift
//  liga1
//

import Foundation

/// Catálogo empaquetado: estadio y capacidad por `id` de equipo (cancha del local).
/// Fuente: `TeamVenues.json` en el bundle. Una sola deserialización por proceso.
enum TeamVenueCatalog {

    struct Info {
        let estadio: String
        let capacidadTexto: String
    }

    private struct RowDTO: Decodable {
        let id: String
        let estadio: String
        let capacidad: Int
    }

    private static let byTeamId: [String: Info] = loadOnce()

    static func info(forLocalTeamId teamId: String?) -> Info? {
        guard let id = teamId?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty else {
            return nil
        }
        return byTeamId[id]
    }

    private static func loadOnce() -> [String: Info] {
        guard let url = Bundle.main.url(forResource: "TeamVenues", withExtension: "json") else {
            return [:]
        }
        guard let data = try? Data(contentsOf: url) else { return [:] }
        let decoder = JSONDecoder()
        guard let rows = try? decoder.decode([RowDTO].self, from: data) else { return [:] }

        var out: [String: Info] = [:]
        out.reserveCapacity(rows.count)
        for row in rows {
            let t = row.estadio.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { continue }
            out[row.id] = Info(estadio: t, capacidadTexto: formatCapacity(row.capacidad))
        }
        return out
    }

    private static func formatCapacity(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "es_PE")
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
