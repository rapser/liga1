//
//  LoginViewController.swift
//  liga1
//
//  Auth/Presentation: pantalla de login.
//

import UIKit
import Combine

class LoginViewController: UIViewController {

    // MARK: - Properties

    let viewModel: LoginViewModel
    private let googleCredentialProvider: GoogleCredentialProvider
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: LoginViewControllerDelegate?

    // MARK: - Initialization

    init(viewModel: LoginViewModel, googleCredentialProvider: GoogleCredentialProvider) {
        self.viewModel = viewModel
        self.googleCredentialProvider = googleCredentialProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - UI Components

    private let containerView = ContainerView()
    private lazy var contentView = UIView().prepareForAutoLayout()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "liga1-logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel = LayoutPresets.titleLabel(text: "Bienvenido", fontSize: 28)
        .alignment(.center)

    private lazy var subtitleLabel = LayoutPresets.subtitleLabel(text: "Inicia sesión para continuar")
        .alignment(.center)

    private lazy var emailTextField: UITextField = {
        let field = LayoutPresets.styledTextField(placeholder: "Correo electrónico")
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = .emailAddress
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        return field
    }()

    private lazy var passwordTextField: UITextField = {
        let field = LayoutPresets.styledTextField(placeholder: "Contraseña")
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        return field
    }()

    private lazy var loginButton = LayoutPresets.primaryButton(
        title: "Iniciar Sesión",
        backgroundColor: .liga1Red
    )

    private lazy var dividerView = LayoutPresets.dividerView()

    private lazy var googleSignInButton = LayoutPresets.googleSignInButton()

    private var loadingComponents: (overlay: UIView, indicator: UIActivityIndicatorView)!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground

        viewModel.delegate = self
        viewModel.coordinatorDelegate = self

        setupLayout()
        setupActions()
        setupKeyboardDismissal()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupLayout() {
        containerView.attachToSafeArea(in: view)
        contentView
            .addTo(containerView)
            .fillSuperview()

        // Logo
        logoImageView
            .addTo(contentView)
            .centerX()
            .pinTop(constant: 80)
            .square(120)

        // Title
        titleLabel
            .addTo(contentView)
            .pinTop(to: logoImageView.bottomAnchor, constant: Spacing.extraLarge)
            .pinHorizontal(padding: Spacing.extraLarge)

        // Subtitle
        subtitleLabel
            .addTo(contentView)
            .pinTop(to: titleLabel.bottomAnchor, constant: Spacing.small)
            .pinHorizontal(padding: Spacing.extraLarge)

        // Email TextField
        emailTextField
            .addTo(contentView)
            .pinTop(to: subtitleLabel.bottomAnchor, constant: 40)
            .pinHorizontal(padding: Spacing.extraLarge)

        // Password TextField
        passwordTextField
            .addTo(contentView)
            .pinTop(to: emailTextField.bottomAnchor, constant: Spacing.standard)
            .pinHorizontal(padding: Spacing.extraLarge)

        // Login Button
        loginButton
            .addTo(contentView)
            .pinTop(to: passwordTextField.bottomAnchor, constant: Spacing.large)
            .pinHorizontal(padding: Spacing.extraLarge)

        // Divider
        dividerView
            .addTo(contentView)
            .pinTop(to: loginButton.bottomAnchor, constant: Spacing.large)
            .pinHorizontal(padding: Spacing.extraLarge)
            .height(40)

        // Google Sign In Button
        googleSignInButton
            .addTo(contentView)
            .pinTop(to: dividerView.bottomAnchor, constant: Spacing.standard)
            .pinHorizontal(padding: Spacing.extraLarge)
            .pinBottom(constant: 40)

        // Loading overlay
        loadingComponents = LayoutPresets.loadingOverlay(in: view, activityIndicatorColor: .liga1Red)
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(title: "Error", message: error)
            }
            .store(in: &cancellables)

    }

    // MARK: - Actions

    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }

        viewModel.login(email: email, password: password)
    }

    @objc private func googleSignInTapped() {
        viewModel.signInWithGoogle()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper Methods

    private func showLoading(_ show: Bool) {
        loadingComponents.overlay.isHidden = !show
        show ? loadingComponents.indicator.startAnimating() : loadingComponents.indicator.stopAnimating()
    }

}

// MARK: - LoginViewModelDelegate

extension LoginViewController: LoginViewModelDelegate {
    func loginViewModelNeedsGoogleSignInPresentation(_ viewModel: LoginViewModel) {
        viewModel.performGoogleSignIn(presentingViewController: self)
    }
}

// MARK: - LoginViewModelCoordinatorDelegate

extension LoginViewController: LoginViewModelCoordinatorDelegate {
    func loginViewModelDidRequestGoogleSignIn(_ viewModel: LoginViewModel) {
        // No se usa actualmente
    }

    func loginViewModelDidLogin(_ viewModel: LoginViewModel, user: User) {
        delegate?.loginViewControllerDidLogin(self, user: user)
    }
}
