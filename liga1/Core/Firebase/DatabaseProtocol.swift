//
//  DatabaseProtocol.swift
//  liga1
//
//  Created by Claude Code on 03/01/26.
//

import Foundation
import FirebaseFirestore

/// Protocolo que abstrae el acceso a la base de datos
/// Permite inyectar dependencias y facilita testing con mocks
public protocol DatabaseProtocol {
    var db: Firestore { get }
}
