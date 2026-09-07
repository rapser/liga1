//
//  ProjectQualificationUseCase.swift
//  liga1
//

import Foundation

protocol ProjectQualificationUseCaseProtocol {
    /// Zona (copas / descenso / ninguna) por equipo, según la posición en `table`.
    /// `table` debe venir ya ordenada. Clave: código de equipo (`Team.logo`).
    func execute(table: [Team], rules: QualificationRules) -> [String: QualificationZone]
}

final class ProjectQualificationUseCase: ProjectQualificationUseCaseProtocol {

    func execute(table: [Team], rules: QualificationRules) -> [String: QualificationZone] {
        let total = table.count
        guard total > 0 else { return [:] }

        let descensoDesde = total - rules.descensoUltimos + 1

        var result: [String: QualificationZone] = [:]
        for (index, team) in table.enumerated() {
            let pos = index + 1
            result[team.logo] = zone(for: pos, descensoDesde: descensoDesde, rules: rules)
        }
        return result
    }

    private func zone(for pos: Int, descensoDesde: Int, rules: QualificationRules) -> QualificationZone {
        if pos >= descensoDesde { return .descenso }
        if rules.libertadores.contains(pos) { return .libertadores }
        if let previa = rules.libertadoresPrevia, previa.contains(pos) { return .libertadoresPrevia }
        if rules.sudamericana.contains(pos) { return .sudamericana }
        return .none
    }
}
