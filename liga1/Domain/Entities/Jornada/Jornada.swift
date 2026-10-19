//
//  Jornada.swift
//  liga1
//
//  Created by miguel tomairo on 08/01/26.
//

import Foundation

/// Entidad de dominio pura que representa una jornada de la liga
/// No tiene dependencias de Firebase ni de ninguna capa externa
struct Jornada {
    let id: String
    let torneo: String
    let numero: Int
    let fechaInicio: Date
    /// Último partido de la jornada. `nil` en jornadas antiguas que no lo guardaron.
    let fechaFin: Date?
    /// Todos los partidos de la jornada ya tienen fecha y hora oficial.
    let horariosConfirmados: Bool

    init(
        id: String,
        torneo: String,
        numero: Int,
        fechaInicio: Date,
        fechaFin: Date? = nil,
        horariosConfirmados: Bool = false
    ) {
        self.id = id
        self.torneo = torneo
        self.numero = numero
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.horariosConfirmados = horariosConfirmados
    }
}

// MARK: - Visibilidad en Home
extension Jornada {

    /// Días de anticipación con los que una jornada con horarios confirmados aparece en Home.
    /// Coincide con el rango del calendario de Home (±7 días).
    static let homeLeadDays = 7

    /// Una jornada se muestra solo si ya tiene horarios oficiales y su rango de partidos cae dentro
    /// de la ventana de Home: empieza como máximo en `hoy + 7 días` y no terminó antes de `hoy - 7 días`.
    /// Los días se cuentan en hora de Lima, igual que el filtro de partidos por día.
    func isVisibleInHome(now: Date = Date()) -> Bool {
        guard horariosConfirmados else { return false }

        let lima = Self.limaCalendar
        let today = lima.startOfDay(for: now)
        guard let windowStart = lima.date(byAdding: .day, value: -Self.homeLeadDays, to: today),
              let windowEnd = lima.date(byAdding: .day, value: Self.homeLeadDays + 1, to: today) else {
            return true
        }

        if fechaInicio >= windowEnd { return false }
        if let fechaFin, fechaFin < windowStart { return false }
        return true
    }

    private static var limaCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Lima") ?? .current
        return calendar
    }
}

// MARK: - Equatable
extension Jornada: Equatable {
    static func == (lhs: Jornada, rhs: Jornada) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Jornada: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
