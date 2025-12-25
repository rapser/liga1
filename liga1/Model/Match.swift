//
//  Match.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import Foundation
import FirebaseFirestore

struct Match: Codable {
    @DocumentID var id: String?
    let equipoLocalId: String
    let equipoVisitanteId: String
    let fecha: Date
    let torneo: Torneo
    let jornada: Int
    var golesEquipoLocal: Int
    var golesEquipoVisitante: Int
    var estado: EstadoMatch

    // isFavorite no se guarda en Firestore, es solo para UI
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case equipoLocalId
        case equipoVisitanteId
        case fecha
        case torneo
        case jornada
        case golesEquipoLocal
        case golesEquipoVisitante
        case estado
        // isFavorite NO está en CodingKeys, por lo que no se codifica/decodifica
    }
    
    init(
        id: String? = nil,
        equipoLocalId: String,
        equipoVisitanteId: String,
        fecha: Date,
        torneo: Torneo,
        jornada: Int,
        golesEquipoLocal: Int = 0,
        golesEquipoVisitante: Int = 0,
        estado: EstadoMatch = .pendiente,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.equipoLocalId = equipoLocalId
        self.equipoVisitanteId = equipoVisitanteId
        self.fecha = fecha
        self.torneo = torneo
        self.jornada = jornada
        self.golesEquipoLocal = golesEquipoLocal
        self.golesEquipoVisitante = golesEquipoVisitante
        self.estado = estado
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
    
    enum Torneo: String, Codable {
        case apertura
        case clausura
    }
    
    // Función para convertir a diccionario compatible con Firestore
    func toDictionary() -> [String: Any] {
        return [
            "equipoLocalId": equipoLocalId,
            "equipoVisitanteId": equipoVisitanteId,
            "fecha": Timestamp(date: fecha),
            "torneo": torneo.rawValue,
            "jornada": jornada,
            "golesEquipoLocal": golesEquipoLocal,
            "golesEquipoVisitante": golesEquipoVisitante,
            "estado": estado.rawValue
        ]
    }
    
    // Generar documentID único
    func documentID() -> String {
        let jornadaString = String(format: "%02d", jornada)
        return "\(torneo.rawValue)_\(jornadaString)_\(equipoLocalId)_\(equipoVisitanteId)"
    }
}

