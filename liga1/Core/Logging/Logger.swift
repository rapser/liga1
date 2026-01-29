//
//  Logger.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation

/// Protocol para logging centralizado
public protocol LoggerProtocol {
    func error(_ message: String, error: Error?)
    func warning(_ message: String)
    func info(_ message: String)
    func debug(_ message: String)
    func getAllLogs() -> String
    func clearLogs()
}

// MARK: - Default Implementations

extension LoggerProtocol {
    public func getAllLogs() -> String {
        return "Logs no disponibles"
    }
    
    public func clearLogs() {
        // Implementación por defecto vacía
    }
}

/// Logger centralizado para toda la aplicación
/// Permite logging en DEBUG y puede extenderse para enviar a analytics en producción
public final class Logger: LoggerProtocol {

    // MARK: - Singleton

    public static let shared: LoggerProtocol = Logger()
    
    // MARK: - Log Storage
    
    private var logs: [String] = []
    private let maxLogs = 10000 // Máximo de logs a mantener en memoria
    private let logQueue = DispatchQueue(label: "com.liga1.logger", attributes: .concurrent)

    private init() {}
    
    // MARK: - Public Methods - Log Retrieval
    
    public func getAllLogs() -> String {
        return logQueue.sync {
            return logs.joined(separator: "\n")
        }
    }
    
    public func clearLogs() {
        logQueue.async(flags: .barrier) { [weak self] in
            self?.logs.removeAll()
        }
    }
    
    private func addLog(_ message: String) {
        logQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let timestamp = DateFormatter.logFormatter.string(from: Date())
            let logEntry = "\(timestamp) \(message)"
            self.logs.append(logEntry)
            
            // Mantener solo los últimos maxLogs
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst(self.logs.count - self.maxLogs)
            }
        }
    }

    // MARK: - Public Methods

    public func error(_ message: String, error: Error? = nil) {
        let fullMessage = "❌ ERROR: \(message)" + (error != nil ? "\n   Details: \(error!.localizedDescription)" : "")
        #if DEBUG
        print(fullMessage)
        #endif
        addLog(fullMessage)
        // TODO: En producción, enviar a servicio de analytics (Firebase Crashlytics, etc.)
    }

    public func warning(_ message: String) {
        let fullMessage = "⚠️ WARNING: \(message)"
        #if DEBUG
        print(fullMessage)
        #endif
        addLog(fullMessage)
        // TODO: En producción, enviar a servicio de analytics
    }

    public func info(_ message: String) {
        let fullMessage = "ℹ️ INFO: \(message)"
        #if DEBUG
        print(fullMessage)
        #endif
        addLog(fullMessage)
    }

    public func debug(_ message: String) {
        let fullMessage = "🔍 DEBUG: \(message)"
        #if DEBUG
        print(fullMessage)
        #endif
        addLog(fullMessage)
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
