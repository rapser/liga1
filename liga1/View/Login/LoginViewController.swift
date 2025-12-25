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

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "liga1-logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bienvenido"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicia sesión para continuar"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Correo electrónico"
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Contraseña"
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar Sesión", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .liga1Red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dividerLeftLine: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dividerLabel: UILabel = {
        let label = UILabel()
        label.text = "o continuar con"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dividerRightLine: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false

        // Logo de Google
        let logoImageView = UIImageView(image: UIImage(named: "g-logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        // Label del texto
        let label = UILabel()
        label.text = "Continuar con Google"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(logoImageView)
        button.addSubview(label)

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),

            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])

        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .liga1Red
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupActions()
        setupKeyboardDismissal()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(loginButton)
        contentView.addSubview(dividerView)
        contentView.addSubview(googleSignInButton)

        dividerView.addSubview(dividerLeftLine)
        dividerView.addSubview(dividerLabel)
        dividerView.addSubview(dividerRightLine)

        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 52),

            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            passwordTextField.heightAnchor.constraint(equalToConstant: 52),

            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 52),

            // Divider View
            dividerView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 32),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            dividerView.heightAnchor.constraint(equalToConstant: 20),

            // Divider Components
            dividerLabel.centerXAnchor.constraint(equalTo: dividerView.centerXAnchor),
            dividerLabel.centerYAnchor.constraint(equalTo: dividerView.centerYAnchor),

            dividerLeftLine.leadingAnchor.constraint(equalTo: dividerView.leadingAnchor),
            dividerLeftLine.trailingAnchor.constraint(equalTo: dividerLabel.leadingAnchor, constant: -12),
            dividerLeftLine.centerYAnchor.constraint(equalTo: dividerView.centerYAnchor),
            dividerLeftLine.heightAnchor.constraint(equalToConstant: 1),

            dividerRightLine.leadingAnchor.constraint(equalTo: dividerLabel.trailingAnchor, constant: 12),
            dividerRightLine.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            dividerRightLine.centerYAnchor.constraint(equalTo: dividerView.centerYAnchor),
            dividerRightLine.heightAnchor.constraint(equalToConstant: 1),

            // Google Sign-In Button
            googleSignInButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 24),
            googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 52),
            googleSignInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            // Loading Overlay
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Loading

    private func showLoading() {
        loadingOverlay.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideLoading() {
        loadingOverlay.isHidden = true
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    // MARK: - Actions

    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            showErrorAlert(message: "Por favor ingresa tu correo y contraseña.")
            return
        }

        showLoading()

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.hideLoading()

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

        showLoading()

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                self?.hideLoading()
                print("Error en Google Sign-In: \(error.localizedDescription)")
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                self?.hideLoading()
                return
            }

            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            guard let idToken = idToken else {
                self?.hideLoading()
                print("Error: No se pudo obtener el token de autenticación.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                self?.hideLoading()

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


