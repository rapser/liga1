//
//  EquipoPeruano.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import Foundation

public enum EquipoPeruano: String, CaseIterable {
    case alianzaLima = "ali"
    case universitario = "uni"
    case sportingCristal = "cri"
    case cienciano = "cie"
    case cuscoFC = "cus"
    case adt = "adt"
    case alianzaAtletico = "atl"
    case melgar = "mel"
    case atleticoGrau = "gra"
    case deportivoGarcilaso = "gar"
    case sportBoys = "sba"
    case chankas = "cha"
    case utcCajamarca = "utc"
    case sportHuancayo = "hua"
    case comerciantesUnidos = "cou"
    case juanpablo = "jpa"
    case cajamarca = "caj"
    case moquegua = "moq"


    public var nombreCompleto: String {
        switch self {
        case .alianzaLima: return "Alianza Lima"
        case .universitario: return "Universitario"
        case .sportingCristal: return "Sporting Cristal"
        case .cienciano: return "Cienciano"
        case .cuscoFC: return "Cusco FC"
        case .adt: return "ADT"
        case .alianzaAtletico: return "Alianza Atlético"
        case .melgar: return "Melgar"
        case .atleticoGrau: return "Atlético Grau"
        case .deportivoGarcilaso: return "Deportivo Garcilaso"
        case .sportBoys: return "Sport Boys"
        case .chankas: return "Los Chankas"
        case .utcCajamarca: return "UTC Cajamarca"
        case .sportHuancayo: return "Sport Huancayo"
        case .comerciantesUnidos: return "Comerciantes Unidos"
        case .juanpablo: return "Juan Pablo II College"
        case .cajamarca: return "FC Cajamarca"
        case .moquegua: return "Deportivo Moquegua"
        }
    }

    public static func obtenerNombreCompleto(paraId id: String) -> String {
        return EquipoPeruano(rawValue: id)?.nombreCompleto ?? "Equipo Desconocido"
    }
}
