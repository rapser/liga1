//
//  MatchUIMapper.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Mapper para convertir entre Match (Domain layer) y MatchUI (Presentation layer)
struct MatchUIMapper {

    static func toUI(from domain: Match) -> MatchUI {
        return MatchUI(
            id: domain.id,
            equipoLocalId: domain.equipoLocalId,
            equipoVisitanteId: domain.equipoVisitanteId,
            fecha: domain.fecha,
            golesEquipoLocal: domain.golesEquipoLocal,
            golesEquipoVisitante: domain.golesEquipoVisitante,
            estado: domain.estado,
            suspendido: domain.suspendido,
            arbitro: domain.arbitro,
            estadio: domain.estadio,
            capacidad: domain.capacidad,
            canalesTV: domain.canalesTV,
            liveStats: domain.liveStats
        )
    }

    static func toUI(from domains: [Match]) -> [MatchUI] {
        return domains.map { toUI(from: $0) }
    }

    static func toDomain(from ui: MatchUI) -> Match {
        return Match(
            id: ui.id,
            equipoLocalId: ui.equipoLocalId,
            equipoVisitanteId: ui.equipoVisitanteId,
            fecha: ui.fecha,
            golesEquipoLocal: ui.golesEquipoLocal,
            golesEquipoVisitante: ui.golesEquipoVisitante,
            estado: ui.estado,
            suspendido: ui.suspendido,
            arbitro: ui.arbitro,
            estadio: ui.estadio,
            capacidad: ui.capacidad,
            canalesTV: ui.canalesTV,
            liveStats: ui.liveStats
        )
    }
}
