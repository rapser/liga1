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
        guard let navigationController = self.navigationController else {
            return
        }
        
        let mainTabBarController = MainTabBarController()
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(mainTabBarController, animated: true)
    }
    
    private func navigateToMainTabBar() {
        let mainTabBarController = MainTabBarController()
        
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
            
            UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationController.pushViewController(mainTabBarController, animated: false)
            }, completion: nil)
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = mainTabBarController
                        window.makeKeyAndVisible()
                    }, completion: nil)
                }
            }
        }
    }

    @objc private func handleGoogleSignIn() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let _ = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Error en Google Sign-In: \(error.localizedDescription)")
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user else { return }
            
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            
            guard let idToken = idToken else {
                print("Error: No se pudo obtener el token de autenticación.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Error al autenticar con Firebase: \(error.localizedDescription)")
                    self?.showErrorAlert(message: error.localizedDescription)
                    return
                }
                
                self?.navigateToMainTabBar()
            }
        }
        
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


