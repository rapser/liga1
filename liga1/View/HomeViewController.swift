//
//  HomeViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    // Propiedades
    private let equipo1Label: UILabel = {
        let label = UILabel()
        label.text = "Equipo 1:"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let golesEquipo1TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Goles equipo 1"
        textField.keyboardType = .numberPad
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let equipo2Label: UILabel = {
        let label = UILabel()
        label.text = "Equipo 2:"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let golesEquipo2TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Goles equipo 2"
        textField.keyboardType = .numberPad
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let registrarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Registrar", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 4/255.0, green: 191/255.0, blue: 81/255.0, alpha: 1.0) // Color verde Interbank
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupTapGesture()
        
        // Add Done button to keyboard for text fields
        golesEquipo1TextField.addDoneButtonOnKeyboard()
        golesEquipo2TextField.addDoneButtonOnKeyboard()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupViews() {
        // Add subviews
        view.addSubview(equipo1Label)
        view.addSubview(golesEquipo1TextField)
        view.addSubview(equipo2Label)
        view.addSubview(golesEquipo2TextField)
        view.addSubview(registrarButton)
    }
    
    private func setupConstraints() {
        // Constraints for equipo1Label
        NSLayoutConstraint.activate([
            equipo1Label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            equipo1Label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            equipo1Label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            equipo1Label.bottomAnchor.constraint(equalTo: golesEquipo1TextField.topAnchor, constant: -10),
            equipo1Label.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Constraints for golesEquipo1TextField
        NSLayoutConstraint.activate([
            golesEquipo1TextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            golesEquipo1TextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            golesEquipo1TextField.topAnchor.constraint(equalTo: equipo1Label.bottomAnchor, constant: 10),
            golesEquipo1TextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Constraints for equipo2Label
        NSLayoutConstraint.activate([
            equipo2Label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            equipo2Label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            equipo2Label.topAnchor.constraint(equalTo: golesEquipo1TextField.bottomAnchor, constant: 10),
            equipo2Label.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Constraints for golesEquipo2TextField
        NSLayoutConstraint.activate([
            golesEquipo2TextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            golesEquipo2TextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            golesEquipo2TextField.topAnchor.constraint(equalTo: equipo2Label.bottomAnchor, constant: 10),
            golesEquipo2TextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Constraints for registrarButton
        NSLayoutConstraint.activate([
            registrarButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registrarButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            registrarButton.topAnchor.constraint(equalTo: golesEquipo2TextField.bottomAnchor, constant: 10),
            registrarButton.heightAnchor.constraint(equalToConstant: 40)
            // No bottom constraint for registrarButton
        ])
    }
    
    
    @objc private func registrarPartido(equipo1: String, golesEquipo1: Int, equipo2: String, golesEquipo2: Int) {
        
        let partidoRef = db.collection("partidos").document()
        
        partidoRef.setData([
            "equipo1": equipo1,
            "goles_equipo1": golesEquipo1,
            "equipo2": equipo2,
            "goles_equipo2": golesEquipo2,
            "fecha": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error al registrar el partido: \(error.localizedDescription)")
            } else {
                self.actualizarEstadisticas(equipo1: equipo1, golesEquipo1: golesEquipo1, equipo2: equipo2, golesEquipo2: golesEquipo2)
            }
        }
    }
    
    func actualizarEstadisticas(equipo1: String, golesEquipo1: Int, equipo2: String, golesEquipo2: Int) {
        // Actualiza las estadísticas para ambos equipos
        actualizarEstadisticasEquipo(equipo: equipo1, golesFavor: golesEquipo1, golesContra: golesEquipo2) { error in
            if let error = error {
                print("Error al actualizar estadísticas del equipo \(equipo1): \(error.localizedDescription)")
            }
        }
        
        actualizarEstadisticasEquipo(equipo: equipo2, golesFavor: golesEquipo2, golesContra: golesEquipo1) { error in
            if let error = error {
                print("Error al actualizar estadísticas del equipo \(equipo2): \(error.localizedDescription)")
            }
        }
    }
    
    private func actualizarEstadisticasEquipo(equipo: String, golesFavor: Int, golesContra: Int, completion: @escaping (Error?) -> Void) {
        
        let equipoRef = db.collection("equipos").document(equipo)
        
        equipoRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let document = document, document.exists else {
                print("No se encontró el equipo \(equipo)")
                completion(nil)
                return
            }
            
            var partidosJugados = document.data()?["partidos_jugados"] as? Int ?? 0
            var partidosGanados = document.data()?["partidos_ganados"] as? Int ?? 0
            var partidosEmpatados = document.data()?["partidos_empatados"] as? Int ?? 0
            var partidosPerdidos = document.data()?["partidos_perdidos"] as? Int ?? 0
            var golesFavorActual = document.data()?["goles_favor"] as? Int ?? 0
            var golesContraActual = document.data()?["goles_contra"] as? Int ?? 0
            var diferenciaGoles = document.data()?["diferencia_goles"] as? Int ?? 0
            var puntos = document.data()?["puntos"] as? Int ?? 0
            
            partidosJugados += 1
            golesFavorActual += golesFavor
            golesContraActual += golesContra
            diferenciaGoles += (golesFavor - golesContra)
            
            if golesFavor > golesContra {
                partidosGanados += 1
                puntos += 3
            } else if golesFavor == golesContra {
                partidosEmpatados += 1
                puntos += 1
            } else {
                partidosPerdidos += 1
            }
            
            let equipoActualizado: [String: Any] = [
                "partidos_jugados": partidosJugados,
                "partidos_ganados": partidosGanados,
                "partidos_empatados": partidosEmpatados,
                "partidos_perdidos": partidosPerdidos,
                "goles_favor": golesFavorActual,
                "goles_contra": golesContraActual,
                "diferencia_goles": diferenciaGoles,
                "puntos": puntos
            ]
            
            equipoRef.updateData(equipoActualizado) { error in
                completion(error)
            }
        }
    }
}
