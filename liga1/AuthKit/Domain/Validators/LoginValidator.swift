//
//  LoginValidator.swift
//  liga1
//
//  AuthKit/Domain/Validators: Validador de credenciales de login.
//  Created on 15/02/26.
//

import Foundation

/// Validador de credenciales para login
/// Extrae la lógica de validación del antiguo LoginUseCase
public struct LoginValidator {

    // MARK: - Validation Errors

    public enum ValidationError: LocalizedError {
        case emptyFields
        case invalidEmailFormat

        public var errorDescription: String? {
            switch self {
            case .emptyFields:
                return "Por favor completa todos los campos"
            case .invalidEmailFormat:
                return "El formato del email no es válido"
            }
        }
    }

    // MARK: - Public Methods

    /// Valida que email y password no estén vacíos y que el email tenga formato válido
    /// - Parameters:
    ///   - email: Email a validar
    ///   - password: Password a validar
    /// - Throws: ValidationError si la validación falla
    public static func validate(email: String, password: String) throws {
        // Validar campos vacíos
        guard !email.isEmpty, !password.isEmpty else {
            throw ValidationError.emptyFields
        }

        // Validar formato de email
        guard isValidEmail(email) else {
            throw ValidationError.invalidEmailFormat
        }
    }

    // MARK: - Private Methods

    /// Valida el formato del email usando regex
    /// - Parameter email: Email a validar
    /// - Returns: true si el formato es válido
    private static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
