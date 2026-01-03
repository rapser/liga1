//
//  SessionManager.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import FirebaseAuth

final class SessionManager {
    
    static let shared = SessionManager()
    private init() {}
    
    private var inactivityTimer: Timer?
    private let inactivityTimeLimit: TimeInterval = 432000 // 5 días (5 * 24 * 60 * 60)
    
    weak var window: UIWindow?
    
    // MARK: - Configuración inicial
    func configure(with window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - Inactividad
    func startInactivityTimer() {
        resetTimer()
    }
    
    func resetTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(timeInterval: inactivityTimeLimit,
                                               target: self,
                                               selector: #selector(showSessionExpiredAlert),
                                               userInfo: nil,
                                               repeats: false)
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            let viewModel = DIContainer.shared.makeLoginViewModel()
            let loginVC = LoginViewController(viewModel: viewModel)
            let nav = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = nav
            print("✅ Usuario cerrado sesión automáticamente por inactividad.")
        } catch let error {
            print("❌ Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Alerta de expiración
    @objc private func showSessionExpiredAlert() {
        logout()
        
        guard let rootVC = window?.rootViewController else { return }
        
        let alert = UIAlertController(title: "Sesión Expirada",
                                      message: "Tu sesión ha terminado por inactividad.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        
        rootVC.present(alert, animated: true)
    }
}
