//
//  MatchWeatherDTO.swift
//  liga1
//

import Foundation

/// Sub-objeto `clima` de `jornadas/{jornadaId}/matches/{matchId}` en Firestore.
/// Lo escribe el Admin web (Open-Meteo). Todos los campos opcionales por robustez.
struct MatchWeatherDTO: Codable {
    let tempC: Double?
    let sensacionC: Double?
    let humedad: Int?
    let vientoKmh: Double?
    let precipProb: Int?
    let codigoWMO: Int?
    let condicion: String?
    let iconoSF: String?
    let horaReferencia: String?
    let fuente: String?
    let sede: String?
    /// `Timestamp` de Firestore; el decoder Codable lo mapea a `Date`.
    let actualizadoEn: Date?
}

/// Envoltura para decodificar solo el campo `clima` del documento de partido
/// (Firestore ignora las claves desconocidas al decodificar).
struct MatchWeatherEnvelopeDTO: Codable {
    let clima: MatchWeatherDTO?
}
