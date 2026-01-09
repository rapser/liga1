//
//  JornadaMapper.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Mapper para convertir entre JornadaDTO (Data Layer) y Jornada (Domain Layer)
struct JornadaMapper {

    /// Convierte JornadaDTO a Jornada (Domain Model puro)
    /// El documentID debe tener formato "torneo_numero" (ej: "apertura_01")
    static func toDomain(from dto: JornadaDTO, documentID: String? = nil) -> Jornada? {
        guard let id = dto.id ?? documentID,
              let mostrar = dto.mostrar else {
            Logger.shared.warning("JornadaMapper: Missing required fields - id: \(dto.id ?? "nil"), mostrar: \(dto.mostrar ?? false)")
            return nil
        }

        // Extraer torneo y numero del documentID si no están en el DTO
        let (torneo, numero): (String, Int)
        
        if let dtoTorneo = dto.torneo, let dtoNumero = dto.numero {
            // Si están en el DTO, usarlos
            torneo = dtoTorneo
            numero = dtoNumero
        } else if let parsed = parseJornadaId(id) {
            // Si no están en el DTO, extraerlos del documentID
            torneo = parsed.torneo
            numero = parsed.numero
            Logger.shared.debug("JornadaMapper: Extracted torneo=\(torneo), numero=\(numero) from documentID: \(id)")
        } else {
            Logger.shared.warning("JornadaMapper: Cannot extract torneo and numero from id: \(id)")
            return nil
        }

        // fechaInicio es opcional - si no está, usar fecha actual
        let fechaInicio = dto.fechaInicio?.dateValue() ?? Date()

        return Jornada(
            id: id,
            torneo: torneo,
            numero: numero,
            mostrar: mostrar,
            fechaInicio: fechaInicio
        )
    }
    
    /// Parsea un jornadaId con formato "torneo_numero" (ej: "apertura_01", "clausura_10")
    /// - Parameter jornadaId: El ID de la jornada en formato "torneo_numero"
    /// - Returns: Tupla con (torneo: String, numero: Int) o nil si el formato es inválido
    private static func parseJornadaId(_ jornadaId: String) -> (torneo: String, numero: Int)? {
        let components = jornadaId.split(separator: "_")
        guard components.count >= 2 else {
            return nil
        }
        
        let torneo = String(components[0]) // "apertura" o "clausura"
        let numeroString = String(components[1]) // "01", "10", etc.
        
        guard let numero = Int(numeroString) else {
            return nil
        }
        
        return (torneo: torneo, numero: numero)
    }

    /// Convierte Jornada (Domain Model) a JornadaDTO
    static func toDTO(from domain: Jornada) -> JornadaDTO {
        return JornadaDTO(
            id: domain.id,
            mostrar: domain.mostrar,
            numero: domain.numero,
            torneo: domain.torneo,
            fechaInicio: Timestamp(date: domain.fechaInicio)
        )
    }

    /// Convierte array de JornadaDTO a array de Jornada
    /// Nota: Este método no recibe documentIDs, así que asume que los DTOs ya tienen id asignado
    static func toDomain(from dtos: [JornadaDTO]) -> [Jornada] {
        return dtos.compactMap { toDomain(from: $0) }
    }
}
