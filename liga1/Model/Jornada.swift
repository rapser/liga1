//
//  Jornada.swift
//  liga1
//
//  Created by Claude on 25/12/25.
//

import Foundation
import FirebaseFirestore

struct Jornada: Codable {
    @DocumentID var id: String?  // Ej: "clausura_01"
    let mostrar: Bool            // true si la jornada debe mostrarse en el home
    let fechaInicio: Date        // Fecha de inicio de la jornada

    // Propiedades computadas para extraer torneo y número del ID
    var torneo: String? {
        guard let id = id else { return nil }
        let components = id.split(separator: "_")
        return components.first.map(String.init)
    }

    var numero: Int? {
        guard let id = id else { return nil }
        let components = id.split(separator: "_")
        guard components.count >= 2 else { return nil }
        return Int(components[1])
    }

    enum CodingKeys: String, CodingKey {
        case id
        case mostrar
        case fechaInicio
    }
}
