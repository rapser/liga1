//
//  JornadaDTO.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para Jornada desde Firestore
struct JornadaDTO: Codable {
    let id: String?
    let numero: Int?
    let torneo: String?
    let fechaInicio: Timestamp?
    let fechaFin: Timestamp?
    let horariosConfirmados: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case numero
        case torneo
        case fechaInicio
        case fechaFin
        case horariosConfirmados
    }

    init(
        id: String? = nil,
        numero: Int?,
        torneo: String?,
        fechaInicio: Timestamp?,
        fechaFin: Timestamp? = nil,
        horariosConfirmados: Bool? = nil
    ) {
        self.id = id
        self.numero = numero
        self.torneo = torneo
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.horariosConfirmados = horariosConfirmados
    }
}
