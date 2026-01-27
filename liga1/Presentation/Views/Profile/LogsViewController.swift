//
//  LogsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 27/01/26.
//

import UIKit

class LogsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.prepareForAutoLayout()
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .systemBackground
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
        view.backgroundColor = .systemBackground
        
        // Agregar componentes a la vista
        textView.addTo(view)
        stackView.addTo(view)
        
        // Constraints
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            copyButton.heightAnchor.constraint(equalToConstant: 50),
            clearButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        
        // Mostrar feedback
        let alert = UIAlertController(
            title: "Copiado",
            message: "Los logs se han copiado al portapapeles",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func clearLogs() {
        let alert = UIAlertController(
            title: "Limpiar Logs",
            message: "¿Estás seguro de que deseas limpiar todos los logs?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Limpiar", style: .destructive) { [weak self] _ in
            Logger.shared.clearLogs()
            self?.loadLogs()
        })
        
        present(alert, animated: true)
    }
}
