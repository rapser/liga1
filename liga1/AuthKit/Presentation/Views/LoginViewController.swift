//
//  LoginViewController.swift
//  liga1
//
//  Auth/Presentation: pantalla de login.
//

import UIKit
import Combine

/// Delegate para comunicar eventos del LoginViewController al Coordinator
protocol LoginViewControllerDelegate: AnyObject {
    func loginViewControllerDidLogin(_ viewController: LoginViewController, user: User)
}

final class LoginViewController: UIViewController {

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

        // Crear un stack vertical para centrar todo el contenido
        let formStackView = UIStackView()
        formStackView.axis = .vertical
        formStackView.spacing = 0
        formStackView.alignment = .fill
        formStackView.distribution = .fill
        formStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(formStackView)

        // Logo
        let logoContainer = UIView()
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainer.topAnchor, constant: 20),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Textos (Title + Subtitle)
        let textsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textsStackView.axis = .vertical
        textsStackView.spacing = 8
        textsStackView.alignment = .fill

        // Campos de texto
        let fieldsStackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = Spacing.standard
        fieldsStackView.alignment = .fill

        // Agregar todos los elementos al stack principal
        formStackView.addArrangedSubview(logoContainer)
        formStackView.setCustomSpacing(Spacing.large, after: logoContainer)

        formStackView.addArrangedSubview(textsStackView)
        formStackView.setCustomSpacing(32, after: textsStackView)

        formStackView.addArrangedSubview(fieldsStackView)
        formStackView.setCustomSpacing(Spacing.large, after: fieldsStackView)

        formStackView.addArrangedSubview(loginButton)
        formStackView.setCustomSpacing(Spacing.large, after: loginButton)

        formStackView.addArrangedSubview(dividerView)
        formStackView.setCustomSpacing(Spacing.standard, after: dividerView)

        formStackView.addArrangedSubview(googleSignInButton)

        // Centrar el stack verticalmente en la pantalla
        NSLayoutConstraint.activate([
            formStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.extraLarge),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.extraLarge),

            // Constraints de altura para divider
            dividerView.heightAnchor.constraint(equalToConstant: 40)
        ])

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
