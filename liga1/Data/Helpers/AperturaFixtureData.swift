//
//  AperturaFixtureData.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation

/// Helper que contiene todos los datos del fixture del Torneo Apertura 2026
struct AperturaFixtureData {
    
    /// Fecha base para todas las jornadas (30 de enero 2026)
    static let fechaBase: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 30
        components.hour = 0
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    /// Retorna los partidos para una jornada específica (1-17)
    static func matchesParaJornada(_ numero: Int) -> [(local: String, visitante: String)] {
        let fixture: [Int: [(String, String)]] = [
            1: [
                ("jpa", "caj"),  // Juan Pablo vs FC Cajamarca
                ("atl", "cus"),  // Alianza Atlético vs Cusco FC
                ("mel", "cie"),  // Melgar vs Cienciano
                ("utc", "gra"),  // UTC vs Atlético Grau
                ("gar", "cri"),  // Deportivo Garcilaso vs Sporting Cristal
                ("hua", "ali"),  // Sport Huancayo vs Alianza Lima
                ("uni", "adt"),  // Universitario vs ADT
                ("sba", "cha"),  // Sport Boys vs Los Chankas
                ("cou", "moq")   // Comerciantes Unidos vs CD Moquegua
            ],
            2: [
                ("cus", "uni"),  // Cusco FC vs Universitario
                ("adt", "sba"),  // ADT vs Sport Boys
                ("ali", "cou"),  // Alianza Lima vs Comerciantes Unidos
                ("cie", "jpa"),  // Cienciano vs Juan Pablo II
                ("gra", "hua"),  // Atlético Grau vs Sport Huancayo
                ("cri", "mel"),  // Sporting Cristal vs Melgar
                ("caj", "gar"),  // FC Cajamarca vs Deportivo Garcilaso
                ("cha", "atl"),  // Los Chankas vs Alianza Atlético
                ("moq", "utc")   // CD Moquegua vs UTC
            ],
            3: [
                ("jpa", "cri"),  // Juan Pablo II vs Sporting Cristal
                ("atl", "ali"),  // Alianza Atlético vs Alianza Lima
                ("mel", "moq"),  // Melgar vs CD Moquegua
                ("utc", "cus"),  // UTC vs Cusco FC
                ("gar", "caj"),  // Deportivo Garcilaso vs FC Cajamarca
                ("uni", "cie"),  // Universitario vs Cienciano
                ("sba", "gra"),  // Sport Boys vs Atlético Grau
                ("cou", "cha"),  // Comerciantes Unidos vs Los Chankas
                ("hua", "adt")   // Sport Huancayo vs ADT (corregido)
            ],
            4: [
                ("cus", "cou"),  // Cusco FC vs Comerciantes Unidos
                ("adt", "utc"),  // ADT vs UTC
                ("ali", "sba"),  // Alianza Lima vs Sport Boys
                ("cie", "atl"),  // Cienciano vs Alianza Atlético
                ("gra", "jpa"),  // Atlético Grau vs Juan Pablo II
                ("cri", "uni"),  // Sporting Cristal vs Universitario
                ("caj", "mel"),  // FC Cajamarca vs Melgar
                ("cha", "hua"),  // Los Chankas vs Sport Huancayo
                ("moq", "gar")   // CD Moquegua vs Deportivo Garcilaso
            ],
            5: [
                ("jpa", "cus"),  // Juan Pablo II vs Cusco FC
                ("atl", "adt"),  // Alianza Atlético vs ADT
                ("mel", "cha"),  // Melgar vs Los Chankas
                ("utc", "ali"),  // UTC vs Alianza Lima
                ("gar", "cie"),  // Deportivo Garcilaso vs Cienciano
                ("hua", "cri"),  // Sport Huancayo vs Sporting Cristal
                ("uni", "caj"),  // Universitario vs FC Cajamarca
                ("sba", "moq"),  // Sport Boys vs CD Moquegua
                ("cou", "gra")   // Comerciantes Unidos vs Atlético Grau
            ],
            6: [
                ("cus", "gar"),  // Cusco FC vs Deportivo Garcilaso
                ("adt", "jpa"),  // ADT vs Juan Pablo II
                ("ali", "mel"),  // Alianza Lima vs Melgar
                ("cie", "sba"),  // Cienciano vs Sport Boys
                ("gra", "caj"),  // Atlético Grau vs FC Cajamarca
                ("cri", "atl"),  // Sporting Cristal vs Alianza Atlético
                ("cha", "uni"),  // Los Chankas vs Universitario
                ("moq", "hua"),  // CD Moquegua vs Sport Huancayo
                ("cou", "utc")   // Comerciantes Unidos vs UTC
            ],
            7: [
                ("cus", "cie"),  // Cusco FC vs Cienciano
                ("jpa", "cha"),  // Juan Pablo II vs Los Chankas
                ("atl", "moq"),  // Alianza Atlético vs CD Moquegua
                ("mel", "gra"),  // Melgar vs Atlético Grau
                ("gar", "ali"),  // Deportivo Garcilaso vs Alianza Lima
                ("hua", "adt"),  // Sport Huancayo vs ADT
                ("cri", "sba"),  // Sporting Cristal vs Sport Boys
                ("uni", "utc"),  // Universitario vs UTC
                ("caj", "cou")   // FC Cajamarca vs Comerciantes Unidos
            ],
            8: [
                ("adt", "mel"),  // ADT vs Melgar
                ("utc", "atl"),  // UTC vs Alianza Atlético
                ("ali", "jpa"),  // Alianza Lima vs Juan Pablo II
                ("cie", "caj"),  // Cienciano vs FC Cajamarca
                ("gra", "gar"),  // Atlético Grau vs Deportivo Garcilaso
                ("cha", "cri"),  // Los Chankas vs Sporting Cristal
                ("sba", "hua"),  // Sport Boys vs Sport Huancayo
                ("moq", "cus"),  // CD Moquegua vs Cusco FC
                ("cou", "uni")   // Comerciantes Unidos vs Universitario
            ],
            9: [
                ("jpa", "utc"),  // Juan Pablo II vs UTC
                ("atl", "gra"),  // Alianza Atlético vs Atlético Grau
                ("mel", "cus"),  // Melgar vs Cusco FC
                ("cie", "adt"),  // Cienciano vs ADT
                ("gar", "sba"),  // Deportivo Garcilaso vs Sport Boys
                ("hua", "cou"),  // Sport Huancayo vs Comerciantes Unidos
                ("cri", "moq"),  // Sporting Cristal vs CD Moquegua
                ("uni", "ali"),  // Universitario vs Alianza Lima
                ("caj", "cha")   // FC Cajamarca vs Los Chankas
            ],
            10: [
                ("cus", "caj"),  // Cusco FC vs FC Cajamarca
                ("adt", "ali"),  // ADT vs Alianza Lima
                ("utc", "hua"),  // UTC vs Sport Huancayo
                ("gra", "cri"),  // Atlético Grau vs Sporting Cristal
                ("uni", "gar"),  // Universitario vs Deportivo Garcilaso
                ("cha", "cie"),  // Los Chankas vs Cienciano
                ("sba", "mel"),  // Sport Boys vs Melgar
                ("moq", "jpa"),  // CD Moquegua vs Juan Pablo II
                ("cou", "atl")   // Comerciantes Unidos vs Alianza Atlético
            ],
            11: [
                ("jpa", "cou"),  // Juan Pablo II vs Comerciantes Unidos
                ("atl", "sba"),  // Alianza Atlético vs Sport Boys
                ("mel", "uni"),  // Melgar vs Universitario
                ("ali", "cus"),  // Alianza Lima vs Cusco FC
                ("cie", "moq"),  // Cienciano vs CD Moquegua
                ("hua", "gar"),  // Sport Huancayo vs Deportivo Garcilaso
                ("cri", "utc"),  // Sporting Cristal vs UTC
                ("caj", "adt"),  // FC Cajamarca vs ADT
                ("cha", "gra")   // Los Chankas vs Atlético Grau
            ],
            12: [
                ("cus", "hua"),  // Cusco FC vs Sport Huancayo
                ("adt", "cha"),  // ADT vs Los Chankas
                ("utc", "cie"),  // UTC vs Cienciano
                ("gar", "mel"),  // Deportivo Garcilaso vs Melgar
                ("gra", "ali"),  // Atlético Grau vs Alianza Lima
                ("uni", "atl"),  // Universitario vs Alianza Atlético
                ("sba", "jpa"),  // Sport Boys vs Juan Pablo II
                ("moq", "caj"),  // CD Moquegua vs FC Cajamarca
                ("cou", "cri")   // Comerciantes Unidos vs Sporting Cristal
            ],
            13: [
                ("jpa", "uni"),  // Juan Pablo II vs Universitario
                ("atl", "hua"),  // Alianza Atlético vs Sport Huancayo
                ("adt", "gra"),  // ADT vs Atlético Grau
                ("mel", "utc"),  // FBC Melgar vs UTC
                ("ali", "moq"),  // Alianza Lima vs Moquegua
                ("cie", "cou"),  // Cienciano vs Comerciantes
                ("cri", "cus"),  // Sporting Cristal vs Cusco FC
                ("caj", "sba"),  // FC Cajamarca vs Sport Boys
                ("cha", "gar")   // Los Chankas vs D. Garcilaso
            ],
            14: [
                ("cus", "cha"),  // Cusco FC vs Los Chankas
                ("utc", "caj"),  // UTC vs FC Cajamarca
                ("ali", "cri"),  // Alianza Lima vs Sporting Cristal
                ("gar", "atl"),  // Deportivo Garcilaso vs Alianza Atlético
                ("hua", "jpa"),  // Sport Huancayo vs Juan Pablo II
                ("gra", "cie"),  // Atlético Grau vs Cienciano
                ("sba", "uni"),  // Sport Boys vs Universitario
                ("moq", "adt"),  // Moquegua vs ADT
                ("cou", "mel")   // Comerciantes Unidos vs Melgar
            ],
            15: [
                ("jpa", "atl"),  // Juan Pablo II vs Alianza Atlético
                ("adt", "cou"),  // ADT vs Comerciantes
                ("mel", "hua"),  // FC Melgar vs Sport Huancayo
                ("cie", "ali"),  // Cienciano vs Alianza Lima
                ("gar", "utc"),  // D. Garcilaso vs UTC
                ("uni", "gra"),  // Universitario vs Atlético Grau
                ("caj", "cri"),  // FC Cajamarca vs Sporting Cristal
                ("cha", "moq"),  // Los Chankas vs Moquegua
                ("sba", "cus")   // Sport Boys vs Cusco FC
            ],
            16: [
                ("cus", "gra"),  // Cusco FC vs Atlético Grau
                ("jpa", "mel"),  // Juan Pablo II vs FC Melgar
                ("atl", "caj"),  // Alianza Atlético vs FC Cajamarca
                ("utc", "sba"),  // UTC vs Sport Boys
                ("ali", "cha"),  // Alianza Lima vs Los Chankas
                ("hua", "cie"),  // Sport Huancayo vs Cienciano
                ("cri", "adt"),  // Sporting Cristal vs ADT
                ("moq", "uni"),  // Moquegua vs Universitario
                ("cou", "gar")   // Comerciantes Unidos vs Deportivo Garcilaso
            ],
            17: [
                ("adt", "cus"),  // ADT vs Cusco FC
                ("mel", "atl"),  // FC Melgar vs Alianza Atlético
                ("cie", "cri"),  // Cienciano vs Sporting Cristal
                ("gar", "jpa"),  // Deportivo Garcilaso vs Juan Pablo II
                ("gra", "moq"),  // Atlético Grau vs CD Moquegua
                ("uni", "hua"),  // Universitario vs Sport Huancayo
                ("caj", "ali"),  // FC Cajamarca vs Alianza Lima
                ("cha", "utc"),  // Los Chankas vs UTC
                ("sba", "cou")   // Sport Boys vs Comerciantes Unidos
            ]
        ]
        
        return fixture[numero] ?? []
    }
    
    /// Crea los objetos Match para una jornada específica
    static func crearMatchesParaJornada(_ numero: Int, fecha: Date) -> [Match] {
        let partidos = matchesParaJornada(numero)
        
        return partidos.map { local, visitante in
            let matchId = "\(local)_\(visitante)"
            return Match(
                id: matchId,
                equipoLocalId: local,
                equipoVisitanteId: visitante,
                fecha: fecha,
                golesEquipoLocal: 0,
                golesEquipoVisitante: 0,
                estado: .pendiente,
                suspendido: false
            )
        }
    }
}
