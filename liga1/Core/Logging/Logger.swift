//
//  Logger.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Protocol para logging centralizado
public protocol LoggerProtocol {
    func error(_ message: String, error: Error?)
    func warning(_ message: String)
    func info(_ message: String)
    func debug(_ message: String)
}

/// Logger centralizado para toda la aplicación
/// Permite logging en DEBUG y puede extenderse para enviar a analytics en producción
public final class Logger: LoggerProtocol {

    // MARK: - Singleton

    public static let shared: LoggerProtocol = Logger()

    private init() {}

    // MARK: - Public Methods

    public func error(_ message: String, error: Error? = nil) {
        #if DEBUG
        print("❌ ERROR: \(message)")
        if let error = error {
            print("   Details: \(error.localizedDescription)")
        }
        #endif
        // TODO: En producción, enviar a servicio de analytics (Firebase Crashlytics, etc.)
    }

    public func warning(_ message: String) {
        #if DEBUG
        print("⚠️ WARNING: \(message)")
        #endif
        // TODO: En producción, enviar a servicio de analytics
    }

    public func info(_ message: String) {
        #if DEBUG
        print("ℹ️ INFO: \(message)")
        #endif
    }

    public func debug(_ message: String) {
        #if DEBUG
        print("🔍 DEBUG: \(message)")
        #endif
    }
}
