//
//  ViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class TorneoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var equipos: [Match] = []
    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["Clausura", "Acumulado"])
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControl()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.selectedSegmentIndex = 0
        cargarEquiposClausura()
    }
    
    // MARK: - Private methods
    
    private func configureSegmentedControl() {
        // Añadir el UISegmentedControl a la vista
        view.addSubview(segmentedControl)
        
        // Configurar auto-layout para el UISegmentedControl
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Configurar el color rojo para el UISegmentedControl
        let liga1RedColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = liga1RedColor
        
        segmentedControl.backgroundColor = .white
        
        // Configurar los atributos de texto
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        
        segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(textAttributes, for: .normal)
        
        // Añadir un target para detectar cambios en el UISegmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }
    
    private func configureTableView() {
        // Añadir el UITableView a la vista del controlador
        view.addSubview(tableView)
        
        // Configurar auto-layout para el UITableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // Anclado al safeAreaLayoutGuide para evitar el TabBar
        ])
        
        // Registrar la celda personalizada
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        
        tableView.allowsSelection = false
        // Asignar delegados
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configurar el encabezado de la tabla
        let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        tableView.tableHeaderView = headerView
    }
    
    func cargarEquiposClausura() {
        let db = Firestore.firestore()
        let equiposRef = db.collection("clausura")
                
        equiposRef.order(by: "points", descending: true)
            .order(by: "goalDifference", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error al obtener los equipos: \(error.localizedDescription)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No se encontraron equipos")
                        return
                    }
                    
                    self.equipos = documents.map { doc in
                        let data = doc.data()
                        return Match(
                            nombre: data["name"] as? String ?? "Sin nombre",
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
                    
                    // Recargar la tabla con los nuevos datos
                    self.tableView.reloadData()
                }
            }
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        self.equipos = []
        
        if sender.selectedSegmentIndex == 0 {
            // Cargar los datos de "Clausura"
            cargarEquiposClausura()
        } else {
            // Cargar los datos acumulados
            cargarEquiposAcumulados()
        }
    }
    
    func cargarEquiposAcumulados() {
        obtenerDatosAcumulados { equiposAcumulados in
            // Asignar los equipos acumulados al array de equipos
            self.equipos = equiposAcumulados
            
            // Ordenar los equipos por puntos y diferencia de goles
            self.equipos.sort {
                if $0.puntos == $1.puntos {
                    return $0.diferenciaGoles > $1.diferenciaGoles
                } else {
                    return $0.puntos > $1.puntos
                }
            }
            
            // Recargar la tabla con los datos acumulados
            self.tableView.reloadData()
        }
    }
    
    func obtenerDatosAcumulados(completion: @escaping ([Match]) -> Void) {
        let db = Firestore.firestore()
        
        var equiposApertura: [String: Match] = [:]
        var equiposClausura: [String: Match] = [:]
        var equiposAcumulados: [Match] = []
        
        let dispatchGroup = DispatchGroup()
        
        // Cargar datos de la colección "Apertura"
        dispatchGroup.enter()
        db.collection("apertura").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    let equipo = Match(
                        nombre: data["name"] as? String ?? "Sin nombre",
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
                    let equipo = Match(
                        nombre: data["name"] as? String ?? "Sin nombre",
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
                    let equipoAcumulado = Match(
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
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equipos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EquipoCell", for: indexPath) as! EquipoTableViewCell
        let equipo = equipos[indexPath.row]
        
        cell.configure(with: equipo)
        
        // Verificar la selección del UISegmentedControl
        if segmentedControl.selectedSegmentIndex == 1 { // Acumulado
            // Cambiar el color de fondo para las celdas basado en la posición
            switch indexPath.row {
            case 0, 1:
                cell.backgroundColor = .lightMustardYellow // Primer lugar
            case 2:
                cell.backgroundColor = .lighterMustardYellow // Tercer lugar
            case 3:
                cell.backgroundColor = .lightestMustardYellow // Cuarto lugar
            case 4...7:
                cell.backgroundColor = .lightPastelSkyBlue // Del quinto al octavo lugar
            case (equipos.count-3)...(equipos.count-1):
                cell.backgroundColor = .lightRed // Últimas 3 posiciones
            default:
                cell.backgroundColor = .white // Resto de las posiciones
            }
        } else { // Clausura
            // No aplicar colores, dejar fondo blanco
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
}


