//
//  AuthProvider.swift
//  liga1
//
//  Created by miguel tomairo on 03/01/26.
//

import Foundation

/// Protocolo que abstrae el acceso al usuario autenticado
/// Permite inyectar dependencias y facilita testing
protocol AuthProvider {
    var currentUserId: String? { get }
}
