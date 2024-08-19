//
//  ViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class TorneoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var equipos: [Equipo] = []
    let tableView = UITableView()
    
    func cargarEquipos() {
        let db = Firestore.firestore()
        let equiposRef = db.collection("apertura")
        
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
                        return Equipo(
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        cargarEquipos()
        configureTableView()
        cargarEquiposAcumulados()
        
        
    }
    
    private func configureTableView() {
        // Añadir el UITableView a la vista del controlador
        view.addSubview(tableView)
        
        // Configurar auto-layout para el UITableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(to: tableView, leading: 0, top: 0, trailing: 0, bottom: 0)
        
        // Registrar la celda personalizada
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        
        tableView.allowsSelection = false
        // Asignar delegados
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configura el encabezado de la tabla
        let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        tableView.tableHeaderView = headerView
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
    
    func obtenerDatosAcumulados(completion: @escaping ([Equipo]) -> Void) {
        let db = Firestore.firestore()
        
        var equiposApertura: [String: Equipo] = [:]
        var equiposClausura: [String: Equipo] = [:]
        var equiposAcumulados: [Equipo] = []
        
        let dispatchGroup = DispatchGroup()
        
        // Cargar datos de la colección "Apertura"
        dispatchGroup.enter()
        db.collection("apertura").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    let equipo = Equipo(
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
        db.collection("teams").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    let equipo = Equipo(
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
                    let equipoAcumulado = Equipo(
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
        
        // Cambiar el color de fondo para las celdas basado en la posición
        switch indexPath.row {
        case 0,1:
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
        
        return cell
    }

}


