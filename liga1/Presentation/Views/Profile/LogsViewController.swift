//
//  LogsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/01/26.
//

import UIKit

class LogsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let containerView = ContainerView()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.prepareForAutoLayout()
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .appBackground
        textView.isEditable = false
        textView.textColor = .label
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.prepareForAutoLayout()
        button.setTitle("Copiar al Portapapeles", for: .normal)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.prepareForAutoLayout()
        button.setTitle("Limpiar Logs", for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [copyButton, clearButton])
        stackView.prepareForAutoLayout()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Logs de la Aplicación"
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .appBackground
        containerView.attachToSafeArea(in: view)
        
        textView
            .addTo(containerView)
            .pinTop()
            .pinLeading()
            .pinTrailing()
        
        stackView
            .addTo(containerView)
            .pinLeading(constant: Spacing.standard)
            .pinTrailing(constant: Spacing.standard)
            .pinBottom(constant: Spacing.standard)
            .height(50)
        
        textView.pinBottom(to: stackView.topAnchor, constant: -Spacing.standard)
        
        copyButton.height(50)
        clearButton.height(50)
    }
    
    private func loadLogs() {
        let logs = Logger.shared.getAllLogs()
        textView.text = logs.isEmpty ? "No hay logs disponibles" : logs
        
        // Scroll al final
        if !logs.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let bottom = NSRange(location: self.textView.text.count - 1, length: 1)
                self.textView.scrollRangeToVisible(bottom)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func copyToClipboard() {
        let logs = Logger.shared.getAllLogs()
        UIPasteboard.general.string = logs
        showAlert(title: "Copiado", message: "Los logs se han copiado al portapapeles")
    }
    
    @objc private func clearLogs() {
        showConfirmation(
            title: "Limpiar Logs",
            message: "¿Estás seguro de que deseas limpiar todos los logs?",
            confirmTitle: "Limpiar",
            cancelTitle: "Cancelar",
            confirmStyle: .destructive
        ) { [weak self] _ in
            Logger.shared.clearLogs()
            self?.loadLogs()
        }
    }
}
