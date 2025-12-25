//
//  Match.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import Foundation
import FirebaseFirestore

struct Match: Codable {
    @DocumentID var id: String?  // Ej: "adt_utc"
    let fecha: Date
    var golesEquipoLocal: Int
    var golesEquipoVisitante: Int
    var estado: EstadoMatch
    var suspendido: Bool

    // isFavorite no se guarda en Firestore, es solo para UI
    var isFavorite: Bool = false

    // Propiedades para UI que se setean desde la jornada padre
    var jornadaNumero: Int = 0
    var torneoNombre: String = ""

    // Propiedades computadas para extraer equipos del ID
    var equipoLocalId: String? {
        guard let id = id else { return nil }
        let components = id.split(separator: "_")
        return components.first.map(String.init)
    }

    var equipoVisitanteId: String? {
        guard let id = id else { return nil }
        let components = id.split(separator: "_")
        guard components.count >= 2 else { return nil }
        return String(components[1])
    }

    enum CodingKeys: String, CodingKey {
        case id
        case fecha
        case golesEquipoLocal
        case golesEquipoVisitante
        case estado
        case suspendido
        // isFavorite, jornadaNumero, torneoNombre NO están en CodingKeys
    }

    init(
        id: String? = nil,
        fecha: Date,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: EstadoMatch = .pendiente,
        suspendido: Bool = false,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.fecha = fecha
        self.golesEquipoLocal = golesEquipoLocal
        self.golesEquipoVisitante = golesEquipoVisitante
        self.estado = estado
        self.suspendido = suspendido
        self.isFavorite = isFavorite
    }
    
    // Enum para estado del partido
    enum EstadoMatch: String, Codable {
        case pendiente
        case enJuego
        case finalizado
        case anulado
        case suspendido
    }
    
    // Función para convertir a diccionario compatible con Firestore
    func toDictionary() -> [String: Any] {
        return [
            "fecha": Timestamp(date: fecha),
            "golesEquipoLocal": golesEquipoLocal,
            "golesEquipoVisitante": golesEquipoVisitante,
            "estado": estado.rawValue,
            "suspendido": suspendido
        ]
    }
}

