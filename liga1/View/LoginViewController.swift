//
//  LoginViewController.swift
//  liga1
//
//  Created by miguel tomairo on 18/10/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewController: UIViewController {

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        return button
    }()
    
    // Botón de Google Sign-In
    let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        loginButton
            .addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(googleSignInButton)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }

    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            showErrorAlert(message: "Please enter email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
            } else {
                self?.navigateToMainTabBar()
            }
        }
    }

    private func navigateToMainTabBar2() {
        // Verificar que estamos dentro de un UINavigationController
        guard let navigationController = self.navigationController else {
            return
        }
        
        // Crear una instancia del MainTabBarController
        let mainTabBarController = MainTabBarController()
        navigationController.setNavigationBarHidden(true, animated: true)
        // Realizar un push
        navigationController.pushViewController(mainTabBarController, animated: true)
    }
    
    private func navigateToMainTabBar() {
        // Crear una instancia del MainTabBarController
        let mainTabBarController = MainTabBarController()
        
        // Verificar que estamos dentro de un UINavigationController
        if let navigationController = self.navigationController {
            // Esconder la barra de navegación
            navigationController.setNavigationBarHidden(true, animated: true)
            
            // Realizar un push con animación
            UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationController.pushViewController(mainTabBarController, animated: false)
            }, completion: nil)
        } else {
            // Obtener la escena activa
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    // Establecer el MainTabBarController como la raíz con animación
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = mainTabBarController
                        window.makeKeyAndVisible()
                    }, completion: nil)
                }
            }
        }
    }

    // Método para iniciar sesión con Google
    @objc private func handleGoogleSignIn() {
        
        // Verifica si hay un clientID configurado en Firebase
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Crear la configuración de Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        
        // Usar el nuevo método `signIn(withPresenting:)`
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Error en Google Sign-In: \(error.localizedDescription)")
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            // Verifica si el usuario está autenticado
            guard let user = result?.user else { return }
            
            // Obtener el token de autenticación de Google y el accessToken
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            
            // Verifica que los tokens no sean nil
            guard let idToken = idToken else {
                print("Error: No se pudo obtener el token de autenticación.")
                return
            }
            
            // Crear la credencial de Google para Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Iniciar sesión en Firebase con las credenciales de Google
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Error al autenticar con Firebase: \(error.localizedDescription)")
                    self?.showErrorAlert(message: error.localizedDescription)
                    return
                }
                
                // Redirigir al TabBar si el login fue exitoso
                self?.navigateToMainTabBar()
            }
        }
        
    }

    // Alerta de error
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


