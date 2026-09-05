//
//  PollMapper.swift
//  liga1
//

import Foundation

/// `PollDTO` (Data) → `RefereePoll` (Domain).
struct PollMapper {

    /// `nil` si al documento le faltan campos imprescindibles (pregunta, opciones, cierre).
    static func toDomain(id: String, dto: PollDTO) -> RefereePoll? {
        guard
            let pregunta = dto.pregunta?.trimmingCharacters(in: .whitespacesAndNewlines),
            !pregunta.isEmpty,
            let cierraEn = dto.cierraEn,
            let dtoOpciones = dto.opciones,
            !dtoOpciones.isEmpty
        else { return nil }

        let opciones: [RefereePoll.Option] = dtoOpciones.compactMap { o in
            guard
                let oid = o.id?.trimmingCharacters(in: .whitespacesAndNewlines), !oid.isEmpty,
                let texto = o.texto?.trimmingCharacters(in: .whitespacesAndNewlines), !texto.isEmpty
            else { return nil }
            return RefereePoll.Option(id: oid, texto: texto)
        }
        guard opciones.count >= 2 else { return nil }

        return RefereePoll(
            id: id,
            matchId: dto.matchId ?? "",
            jornadaId: dto.jornadaId ?? "",
            pregunta: pregunta,
            opciones: opciones,
            estado: RefereePoll.Estado(rawValue: dto.estado ?? "activa") ?? .activa,
            cierraEn: cierraEn,
            creadoEn: dto.creadoEn,
            numShards: max(1, dto.numShards ?? 10)
        )
    }

    /// Suma los shards en un único conteo por `optionId`.
    static func tally(fromShards shards: [PollShardDTO]) -> [String: Int] {
        var out: [String: Int] = [:]
        for shard in shards {
            for (optionId, count) in shard.counts ?? [:] {
                out[optionId, default: 0] += count
            }
        }
        return out
    }
}
