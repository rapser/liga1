//
//  NotificationHistoryViewController.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//

import UIKit
import UserNotifications

class NotificationHistoryViewController: UIViewController {
    
    // MARK: - Properties
    
    private let containerView = ContainerView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.prepareForAutoLayout()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay notificaciones en el historial"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private var notifications: [UNNotification] = []
    private var isLoading = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Historial"
        setupTableView()
        loadNotificationHistory()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        containerView.attachToSafeArea(in: view)
        tableView
            .addTo(containerView)
            .fillSuperview()
        emptyLabel
            .addTo(containerView)
            .centerInSuperview()
    }
    
    // MARK: - Load Data
    
    private func loadNotificationHistory() {
        isLoading = true
        
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.notifications = notifications.sorted { notification1, notification2 in
                    // Ordenar por fecha más reciente primero
                    return notification1.date > notification2.date
                }
                self?.tableView.reloadData()
                if notifications.isEmpty {
                    self?.emptyLabel.isHidden = false
                } else {
                    self?.emptyLabel.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: date)
    }
}

// MARK: - UITableViewDataSource

extension NotificationHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let notification = notifications[indexPath.row]
        let content = notification.request.content
        
        // Configurar celda con estilo subtitle para mejor presentación
        cell.textLabel?.text = content.title
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        cell.detailTextLabel?.text = "\(content.body)\n\n\(formatDate(notification.date))"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NotificationHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        let content = notification.request.content
        
        // Mostrar detalles de la notificación
        let alert = UIAlertController(
            title: content.title,
            message: "\(content.body)\n\nFecha: \(formatDate(notification.date))",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Aumentar altura estimada para mejor presentación
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            let notification = self.notifications[indexPath.row]
            let identifier = notification.request.identifier
            
            // Remover la notificación del Notification Center
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
            
            // Remover de la lista local
            self.notifications.remove(at: indexPath.row)
            
            // Animar la eliminación
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Si no quedan notificaciones, mostrar estado vacío
            if self.notifications.isEmpty {
                self.emptyLabel.isHidden = false
            }
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
