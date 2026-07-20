//
//  TorneoType.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

public enum TorneoType: String, CaseIterable {
    case apertura = "apertura"
    case clausura = "clausura"
    case acumulado = "acumulado"

    public var displayName: String {
        switch self {
        case .apertura: return "Apertura"
        case .clausura: return "Clausura"
        case .acumulado: return "Acumulado"
        }
    }
}
