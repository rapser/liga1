//
//  ViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class TorneoViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["Apertura", "Clausura", "Acumulado"])
    
    private var equiposApertura: [Team] = []
    private var equiposClausura: [Team] = []
    private var equiposAcumulados: [Team] = []
    var equiposMostrados: [Team] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSegmentedControl()
        configureTableView()
        loadInitialData()
    }
    
    // MARK: - Private methods
    
    private func loadInitialData() {
        segmentedControl.selectedSegmentIndex = 1
        cargarEquipos(torneo: .clausura) { [weak self] in
            self?.equiposClausura = self?.equiposMostrados ?? []
        }
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let liga1RedColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = liga1RedColor
        segmentedControl.backgroundColor = .systemBackground
                
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]

        segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        tableView.sectionHeaderTopPadding = 0

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    private func obtenerNombreCompleto(paraId id: String) -> String {
        return EquipoPeruano.obtenerNombreCompleto(paraId: id)
    }
    
    // MARK: - Data Loading
    
    func cargarEquipos(torneo: TorneoType, completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        let equiposRef = db.collection(torneo.rawValue)
                
        equiposRef.order(by: "points", descending: true)
            .order(by: "goalDifference", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error al obtener los equipos de \(torneo.rawValue): \(error.localizedDescription)")
                    completion?()
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No se encontraron equipos en \(torneo.rawValue)")
                    completion?()
                    return
                }
                
                self.equiposMostrados = documents.map { doc in
                    let data = doc.data()
                    return Team(
                        nombre: self.obtenerNombreCompleto(paraId: doc.documentID),
                        ciudad: data["city"] as? String ?? "Sin ciudad",
                        estadio: data["stadium"] as? String ?? "Sin estadio",
                        logo: data["logo"] as? String ?? "Sin logo",
                        partidosJugados: data["matchesPlayed"] as? Int ?? 0,
                        partidosGanados: data["matchesWon"] as? Int ?? 0,
                        partidosEmpatados: data["matchesDrawn"] as? Int ?? 0,
                        partidosPerdidos: data["matchesLost"] as? Int ?? 0,
                        golesFavor: data["goalsScored"] as? Int ?? 0,
                        golesContra: data["goalsAgainst"] as? Int ?? 0,
                        diferenciaGoles: data["goalDifference"] as? Int ?? 0,
                        puntos: data["points"] as? Int ?? 0
                    )
                }
                
                // Guardar en cache según el torneo
                switch torneo {
                case .apertura:
                    self.equiposApertura = self.equiposMostrados
                case .clausura:
                    self.equiposClausura = self.equiposMostrados
                case .acumulado:
                    print("sin guardar")
                }
                
                self.tableView.reloadData()
                completion?()
            }
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Apertura
            if equiposApertura.isEmpty {
                cargarEquipos(torneo: .apertura) { [weak self] in
                    self?.equiposApertura = self?.equiposMostrados ?? []
                }
            } else {
                equiposMostrados = equiposApertura
                tableView.reloadData()
            }
            
        case 1: // Clausura
            if equiposClausura.isEmpty {
                cargarEquipos(torneo: .clausura) { [weak self] in
                    self?.equiposClausura = self?.equiposMostrados ?? []
                }
            } else {
                equiposMostrados = equiposClausura
                tableView.reloadData()
            }
            
        case 2: // Acumulado
            if equiposAcumulados.isEmpty {
                cargarEquiposAcumulados()
            } else {
                equiposMostrados = equiposAcumulados
                tableView.reloadData()
            }
            
        default:
            break
        }
    }
    
    func cargarEquiposAcumulados() {
        obtenerDatosAcumulados { [weak self] equiposAcumulados in
            guard let self = self else { return }
            
            self.equiposAcumulados = equiposAcumulados.sorted {
                if $0.puntos == $1.puntos {
                    return $0.diferenciaGoles > $1.diferenciaGoles
                } else {
                    return $0.puntos > $1.puntos
                }
            }
            
            self.equiposMostrados = self.equiposAcumulados
            self.tableView.reloadData()
        }
    }
    
    func obtenerDatosAcumulados(completion: @escaping ([Team]) -> Void) {
        let db = Firestore.firestore()
        
        var equiposApertura: [String: Team] = [:]
        var equiposClausura: [String: Team] = [:]
        var equiposAcumulados: [Team] = []
        
        let dispatchGroup = DispatchGroup()
        
        // Cargar datos de la colección "Apertura"
        dispatchGroup.enter()
        db.collection("apertura").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    let equipo = Team(
                        nombre: self.obtenerNombreCompleto(paraId: document.documentID),
                        ciudad: data["city"] as? String ?? "Sin ciudad",
                        estadio: data["stadium"] as? String ?? "Sin estadio",
                        logo: data["logo"] as? String ?? "Sin logo",
                        partidosJugados: data["matchesPlayed"] as? Int ?? 0,
                        partidosGanados: data["matchesWon"] as? Int ?? 0,
                        partidosEmpatados: data["matchesDrawn"] as? Int ?? 0,
                        partidosPerdidos: data["matchesLost"] as? Int ?? 0,
                        golesFavor: data["goalsScored"] as? Int ?? 0,
                        golesContra: data["goalsAgainst"] as? Int ?? 0,
                        diferenciaGoles: data["goalDifference"] as? Int ?? 0,
                        puntos: data["points"] as? Int ?? 0
                    )
                    equiposApertura[document.documentID] = equipo
                }
            }
            dispatchGroup.leave()
        }
        
        // Cargar datos de la colección "Clausura"
        dispatchGroup.enter()
        db.collection("clausura").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    let equipo = Team(
                        nombre: self.obtenerNombreCompleto(paraId: document.documentID),
                        ciudad: data["city"] as? String ?? "Sin ciudad",
                        estadio: data["stadium"] as? String ?? "Sin estadio",
                        logo: data["logo"] as? String ?? "Sin logo",
                        partidosJugados: data["matchesPlayed"] as? Int ?? 0,
                        partidosGanados: data["matchesWon"] as? Int ?? 0,
                        partidosEmpatados: data["matchesDrawn"] as? Int ?? 0,
                        partidosPerdidos: data["matchesLost"] as? Int ?? 0,
                        golesFavor: data["goalsScored"] as? Int ?? 0,
                        golesContra: data["goalsAgainst"] as? Int ?? 0,
                        diferenciaGoles: data["goalDifference"] as? Int ?? 0,
                        puntos: data["points"] as? Int ?? 0
                    )
                    equiposClausura[document.documentID] = equipo
                }
            }
            dispatchGroup.leave()
        }
        
        // Esperar a que se carguen ambas colecciones
        dispatchGroup.notify(queue: .main) {
            for (documentID, equipoApertura) in equiposApertura {
                if let equipoClausura = equiposClausura[documentID] {
                    // Sumar los valores de ambos torneos
                    let equipoAcumulado = Team(
                        nombre: equipoApertura.nombre,
                        ciudad: equipoApertura.ciudad,
                        estadio: equipoApertura.estadio,
                        logo: equipoApertura.logo,
                        partidosJugados: equipoApertura.partidosJugados + equipoClausura.partidosJugados,
                        partidosGanados: equipoApertura.partidosGanados + equipoClausura.partidosGanados,
                        partidosEmpatados: equipoApertura.partidosEmpatados + equipoClausura.partidosEmpatados,
                        partidosPerdidos: equipoApertura.partidosPerdidos + equipoClausura.partidosPerdidos,
                        golesFavor: equipoApertura.golesFavor + equipoClausura.golesFavor,
                        golesContra: equipoApertura.golesContra + equipoClausura.golesContra,
                        diferenciaGoles: equipoApertura.diferenciaGoles + equipoClausura.diferenciaGoles,
                        puntos: equipoApertura.puntos + equipoClausura.puntos
                    )
                    equiposAcumulados.append(equipoAcumulado)
                }
            }
            completion(equiposAcumulados)
        }
    }
}

