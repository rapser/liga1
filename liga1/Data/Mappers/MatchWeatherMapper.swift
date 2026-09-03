//
//  MatchWeatherMapper.swift
//  liga1
//

import Foundation

/// Convierte `MatchWeatherDTO` (Data) → `MatchWeather` (Domain).
struct MatchWeatherMapper {

    /// `nil` si el sub-objeto no trae al menos temperatura y condición útiles.
    static func toDomain(from dto: MatchWeatherDTO) -> MatchWeather? {
        guard let temp = dto.tempC else { return nil }

        let condition = dto.condicion
            .flatMap { MatchWeather.Condition(rawValue: $0) } ?? .desconocido

        return MatchWeather(
            temperatureC: temp,
            feelsLikeC: dto.sensacionC ?? temp,
            humidityPct: clampPercent(dto.humedad),
            windKmh: max(0, dto.vientoKmh ?? 0),
            precipitationProbPct: clampPercent(dto.precipProb),
            wmoCode: dto.codigoWMO ?? -1,
            condition: condition,
            symbol: dto.iconoSF?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            referenceHour: dto.horaReferencia ?? "",
            updatedAt: dto.actualizadoEn,
            stadiumCode: nonEmpty(dto.sede)
        )
    }

    private static func clampPercent(_ value: Int?) -> Int {
        guard let value else { return 0 }
        return min(100, max(0, value))
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let t = value?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }
}
