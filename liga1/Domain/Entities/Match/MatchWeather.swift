//
//  MatchWeather.swift
//  liga1
//

import Foundation

/// Clima estimado para la sede de un partido (Sabor Local).
/// Lo escribe el Admin web desde Open-Meteo en el sub-objeto `clima` del
/// documento `jornadas/{jornadaId}/matches/{matchId}`. Entidad de dominio pura.
struct MatchWeather {

    /// Condición normalizada; el String coincide con lo que persiste el Admin.
    enum Condition: String {
        case despejado
        case nubes
        case niebla
        case lluvia
        case chubascos
        case tormenta
        case nieve
        case desconocido

        /// Etiqueta corta para la UI.
        var displayName: String {
            switch self {
            case .despejado: return "Despejado"
            case .nubes: return "Nublado"
            case .niebla: return "Niebla"
            case .lluvia: return "Lluvia"
            case .chubascos: return "Chubascos"
            case .tormenta: return "Tormenta"
            case .nieve: return "Nieve"
            case .desconocido: return "—"
            }
        }

        /// SF Symbol de reserva si el Admin no envió `iconoSF`.
        var fallbackSymbol: String {
            switch self {
            case .despejado: return "sun.max.fill"
            case .nubes: return "cloud.fill"
            case .niebla: return "cloud.fog.fill"
            case .lluvia: return "cloud.rain.fill"
            case .chubascos: return "cloud.heavyrain.fill"
            case .tormenta: return "cloud.bolt.rain.fill"
            case .nieve: return "snowflake"
            case .desconocido: return "thermometer.medium"
            }
        }
    }

    let temperatureC: Double
    let feelsLikeC: Double
    let humidityPct: Int
    let windKmh: Double
    let precipitationProbPct: Int
    let wmoCode: Int
    let condition: Condition
    /// SF Symbol sugerido por el Admin; si viene vacío se usa `condition.fallbackSymbol`.
    let symbol: String
    /// Hora local (America/Lima) del forecast usado, ISO sin zona: "2026-09-05T18:00".
    let referenceHour: String
    /// Momento en que el Admin refrescó el dato; `nil` si el back no lo guardó.
    let updatedAt: Date?
    /// Doc id en `stadiums/` que se usó para el forecast.
    let stadiumCode: String?

    init(
        temperatureC: Double,
        feelsLikeC: Double,
        humidityPct: Int,
        windKmh: Double,
        precipitationProbPct: Int,
        wmoCode: Int,
        condition: Condition,
        symbol: String,
        referenceHour: String,
        updatedAt: Date? = nil,
        stadiumCode: String? = nil
    ) {
        self.temperatureC = temperatureC
        self.feelsLikeC = feelsLikeC
        self.humidityPct = humidityPct
        self.windKmh = windKmh
        self.precipitationProbPct = precipitationProbPct
        self.wmoCode = wmoCode
        self.condition = condition
        self.symbol = symbol.isEmpty ? condition.fallbackSymbol : symbol
        self.referenceHour = referenceHour
        self.updatedAt = updatedAt
        self.stadiumCode = stadiumCode
    }
}

// MARK: - Reglas de dominio

extension MatchWeather {
    /// Temperatura redondeada a entero para titulares ("18°").
    var roundedTemperature: Int { Int(temperatureC.rounded()) }

    /// Sensación térmica distinta de la temperatura (para mostrarla solo si aporta).
    var sensationDiffers: Bool { abs(feelsLikeC - temperatureC) >= 1 }

    /// Umbral a partir del cual conviene destacar la probabilidad de lluvia.
    var lluviaProbable: Bool { precipitationProbPct >= 40 }
}

// MARK: - Equatable

extension MatchWeather: Equatable {}
