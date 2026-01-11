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
    let mostrar: Bool?
    let numero: Int?
    let torneo: String?
    let fechaInicio: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case mostrar
        case numero
        case torneo
        case fechaInicio
    }

    init(id: String? = nil, mostrar: Bool?, numero: Int?, torneo: String?, fechaInicio: Timestamp?) {
        self.id = id
        self.mostrar = mostrar
        self.numero = numero
        self.torneo = torneo
        self.fechaInicio = fechaInicio
    }
}
