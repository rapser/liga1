//
//  PartidoViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import FirebaseFirestore

class PartidoViewController: UIViewController {
    
    // Configuración de Firestore
    let db = Firestore.firestore()
    
    // Definir el botón como una propiedad de la clase
    private let aceptarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aceptar", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        view.addSubview(aceptarButton)
        
        // Configurar las restricciones de Auto Layout
        NSLayoutConstraint.activate([
            aceptarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aceptarButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aceptarButton.widthAnchor.constraint(equalToConstant: 150),
            aceptarButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Añadir la acción para el evento touchUpInside
        aceptarButton.addTarget(self, action: #selector(aceptarTapped), for: .touchUpInside)

    }
    
    // MARK: - Liga 1
    
    func registerMatch(){
        
        // Array de partidos a registrar
        let partidosARegistrar: [Partido] = [
            Partido(teamAId: "com", teamBId: "gra", fecha: "03", golesTeamA: 0, golesTeamB: 0),
            Partido(teamAId: "mel", teamBId: "cou", fecha: "06", golesTeamA: 0, golesTeamB: 0),
            
            Partido(teamAId: "utc", teamBId: "cie", fecha: "10", golesTeamA: 2, golesTeamB: 0),
            Partido(teamAId: "gar", teamBId: "adt", fecha: "10", golesTeamA: 0, golesTeamB: 1),
            Partido(teamAId: "val", teamBId: "com", fecha: "10", golesTeamA: 1, golesTeamB: 0),
            Partido(teamAId: "cus", teamBId: "cou", fecha: "10", golesTeamA: 4, golesTeamB: 0),
            Partido(teamAId: "sba", teamBId: "gra", fecha: "10", golesTeamA: 2, golesTeamB: 1),
            Partido(teamAId: "hua", teamBId: "cri", fecha: "10", golesTeamA: 2, golesTeamB: 1),
            Partido(teamAId: "ali", teamBId: "man", fecha: "10", golesTeamA: 3, golesTeamB: 1),
            Partido(teamAId: "atl", teamBId: "uni", fecha: "10", golesTeamA: 3, golesTeamB: 3),
            Partido(teamAId: "mel", teamBId: "cha", fecha: "10", golesTeamA: 1, golesTeamB: 1)
        ]

        registerMultipleMatches(partidos: partidosARegistrar)
        
        
//        let partido = Partido(teamAId: "cha", teamBId: "man", fecha: "07", golesTeamA: 0, golesTeamB: 0)
//        registerMatch(partido: partido)
        
    }
    
    func iniciarPartido() {
        
//        let matchesToUpdate: [(teamAId: String,
//                               teamBId: String,
//                               fecha: String,
//                               teamAScore: Int,
//                               teamBScore: Int)] = [
//                                ("com", "cha", "01", 1, 2),
//                                ("adt", "cri", "01", 3, 1),
//                                ("gar", "utc", "01", 1, 0),
//                                ("cou", "cie", "01", 1, 2),
//                                ("val", "ali", "01", 2, 3),
//                                ("uni", "man", "01", 6, 0),
//                                ("atl", "gra", "01", 0, 0),
//                                ("sba", "hua", "01", 2, 1),
//                                ("cus", "mel", "01", 0, 3),
//                                ("utc", "cus", "02", 2, 1),
//                                ("hua", "gar", "02", 1, 0),
//                                ("cha", "cou", "02", 2, 0),
//                                ("mel", "val", "02", 5, 2),
//                                ("ali", "atl", "02", 2, 0),
//                                ("gra", "uni", "02", 1, 1),
//                                ("man", "com", "02", 0, 0),
//                                ("cri", "sba", "02", 4, 0),
//                                ("cie", "adt", "02", 0, 1),
//                                ("atl", "mel", "03", 3, 1),
//                                ("cus", "hua", "03", 3, 0),
//                                ("val", "utc", "03", 2, 0),
//                                ("cou", "man", "03", 2, 1),
//                                ("gar", "sba", "03", 2, 0),
//                                ("uni", "ali", "03", 2, 1),
//                                ("cri", "cie", "03", 5, 1),
//                                ("adt", "cha", "03", 2, 1),
//                                ("gar", "cus", "04", 0, 2),
//                                ("hua", "val", "04", 1, 0),
//                                ("sba", "cie", "04", 2, 0),
//                                ("ali", "com", "04", 1, 0),
//                                ("gra", "cou", "04", 3, 0),
//                                ("cha", "cri", "04", 3, 3),
//                                ("man", "adt", "04", 3, 2),
//                                ("mel", "uni", "04", 1, 0),
//                                ("utc", "atl", "04", 1, 1),
//                                ("cou", "ali", "05", 1, 3),
//                                ("cie", "cha", "05", 0, 0),
//                                ("val", "gar", "05", 0, 2),
//                                ("cri", "man", "05", 4, 0),
//                                ("com", "mel", "05", 2, 1),
//                                ("adt", "gra", "05", 1, 2),
//                                ("uni", "utc", "05", 1, 0),
//                                ("atl", "hua", "05", 1, 1),
//                                ("cus", "sba", "05", 3, 1),
//                                ("utc", "com", "06", 3, 1),
//                                ("gar", "atl", "06", 0, 1),
//                                ("sba", "cha", "06", 2, 1),
//                                ("ali", "adt", "06", 0, 0),
//                                ("gra", "cri", "06", 1, 1),
//                                ("man", "cie", "06", 1, 2),
//                                ("hua", "uni", "06", 1, 1),
//                                ("cus", "val", "06", 2, 1),
//                                ("atl", "cus", "07", 1, 1),
//                                ("cou", "utc", "07", 1, 1),
//                                ("adt", "mel", "07", 1, 1),
//                                ("val", "sba", "07", 2, 2),
//                                ("uni", "gar", "07", 3, 1),
//                                ("com", "hua", "07", 0, 1),
//                                ("cie", "gra", "07", 1, 0),
//                                ("cri", "ali", "07", 0, 0)
//                               ]
//        
//        for match in matchesToUpdate {
//            updateLiveMatch(teamAId: match.teamAId, teamBId: match.teamBId, fecha: match.fecha, teamAScore: match.teamAScore, teamBScore: match.teamBScore)
//        }
//        
//        updateMultipleMatches(matches: matchesToUpdate)
        
        let match: (teamAId: String,
                            teamBId: String,
                            fecha: String,
                            teamAScore: Int,
                            teamBScore: Int) =
                            ("cha", "man", "07", 0, 0)
        
        updateLiveMatch(teamAId: match.teamAId, teamBId: match.teamBId, fecha: match.fecha, teamAScore: match.teamAScore, teamBScore: match.teamBScore)

        
    }
    
    func actualizarPartidoVivo(golA: Int, golB: Int) {
        let match: (teamAId: String,
                            teamBId: String,
                            fecha: String,
                            teamAScore: Int,
                            teamBScore: Int) =
                            ("cha", "man", "07", golA, golB)
        
        updateMatch(teamAId: match.teamAId, teamBId: match.teamBId, fecha: match.fecha, teamAScore: match.teamAScore, teamBScore: match.teamBScore)
    }
    
    @objc func aceptarTapped() {
        print("Botón Aceptar presionado")
        
//        initializeTeams()

//        registerMatch()
//        iniciarPartido()
//        finalizarTodosLosPartidos()

        
//        saveInitialStatsToUserDefaults(teamId: "cha")
//        saveInitialStatsToUserDefaults(teamId: "man")
//        actualizarPartidoVivo(golA: 1, golB: 1)
//        finalizarPartido(teamAId: "cha", teamBId: "man", fecha: "07")

//        actualizarTablaPosiciones()
        
    }
    
    // MARK: - Metodos
    
    // En vivo
    
    func clearInitialStats(for teamId: String) {
        let userDefaults = UserDefaults.standard
        let key = "teamStats_\(teamId)"
        
        if userDefaults.object(forKey: key) != nil {
            userDefaults.removeObject(forKey: key)
            print("Estadísticas iniciales eliminadas correctamente para el equipo con ID \(teamId).")
        } else {
            print("No se encontraron estadísticas iniciales para el equipo con ID \(teamId).")
        }
    }
    
    func saveInitialStatsToUserDefaults(teamId: String) {
        let db = Firestore.firestore()
        let teamRef = db.collection("clausura").document(teamId)
        
        teamRef.getDocument { (document, error) in
            if let error = error {
                print("Error al obtener el equipo con ID \(teamId): \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("El equipo no existe o los datos no están disponibles.")
                return
            }
            
            // Extraer las estadísticas iniciales
            let initialStats = [
                "matchesPlayed": data["matchesPlayed"] as? Int ?? 0,
                "goalsScored": data["goalsScored"] as? Int ?? 0,
                "goalsAgainst": data["goalsAgainst"] as? Int ?? 0,
                "goalDifference": data["goalDifference"] as? Int ?? 0,
                "points": data["points"] as? Int ?? 0,
                "matchesDrawn": data["matchesDrawn"] as? Int ?? 0,
                "matchesLost": data["matchesLost"] as? Int ?? 0,
                "matchesWon": data["matchesWon"] as? Int ?? 0
            ] as [String : Any]
            
            // Guardar estadísticas iniciales en UserDefaults
            UserDefaults.standard.set(initialStats, forKey: "teamStats_\(teamId)")
            print("Estadísticas iniciales guardadas correctamente para el equipo con ID \(teamId).")
        }
    }
    
    func updateMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) {
        let db = Firestore.firestore()
        let documentId = "clausura_\(fecha)_\(teamAId)_\(teamBId)"
        
        let matchRef = db.collection("matches").document(documentId)
        
        matchRef.updateData([
            "golesTeamA": teamAScore,
            "golesTeamB": teamBScore
        ]) { error in
            if let error = error {
                print("Error al actualizar el partido con ID \(documentId): \(error.localizedDescription)")
            } else {
                print("Partido actualizado con éxito con ID \(documentId)")
                self.updateLiveMatchStats(documentId)
            }
        }
    }
    
    func updateLiveMatchStats(_ matchId: String) {
        let db = Firestore.firestore()
                
        let matchRef = db.collection("matches").document(matchId)
        matchRef.getDocument { (document, error) in
            if let error = error {
                print("Error al obtener el partido en vivo: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("El partido no existe o los datos no están disponibles.")
                return
            }
            
            let teamAId = data["teamAId"] as? String ?? ""
            let teamBId = data["teamBId"] as? String ?? ""
            let golesTeamA = data["golesTeamA"] as? Int ?? 0
            let golesTeamB = data["golesTeamB"] as? Int ?? 0
            
            self.updateTeamStats(teamId: teamAId, golesScored: golesTeamA, golesAgainst: golesTeamB)
            self.updateTeamStats(teamId: teamBId, golesScored: golesTeamB, golesAgainst: golesTeamA)
        }
    }

    func updateTeamStats(teamId: String, golesScored: Int, golesAgainst: Int) {
        let db = Firestore.firestore()
        let teamRef = db.collection("clausura").document(teamId)
        
        // Recuperar estadísticas iniciales desde UserDefaults
        guard let initialStats = UserDefaults.standard.dictionary(forKey: "teamStats_\(teamId)") as? [String: Int] else {
            print("No se encontraron estadísticas iniciales para el equipo con ID \(teamId)")
            return
        }
        
        // Desempaquetar valores iniciales
        let initialMatchesPlayed = initialStats["matchesPlayed"] ?? 0
        let initialGoalsScored = initialStats["goalsScored"] ?? 0
        let initialGoalsAgainst = initialStats["goalsAgainst"] ?? 0
        let initialGoalDifference = initialStats["goalDifference"] ?? 0
        let initialPoints = initialStats["points"] ?? 0
        let initialMatchesDrawn = initialStats["matchesDrawn"] ?? 0
        let initialMatchesLost = initialStats["matchesLost"] ?? 0
        let initialMatchesWon = initialStats["matchesWon"] ?? 0
        
        // Variables actualizadas
        var updatedMatchesPlayed = initialMatchesPlayed
        var updatedGoalsScored = initialGoalsScored
        var updatedGoalsAgainst = initialGoalsAgainst
        var updatedGoalDifference = initialGoalDifference
        var updatedPoints = initialPoints
        var updatedMatchesDrawn = initialMatchesDrawn
        var updatedMatchesLost = initialMatchesLost
        var updatedMatchesWon = initialMatchesWon
        
        // Determinar el resultado del partido
        if golesScored > golesAgainst {
            updatedPoints += 3 // Victoria
            updatedMatchesWon += 1
        } else if golesScored == golesAgainst {
            updatedPoints += 1 // Empate
            updatedMatchesDrawn += 1
        } else {
            updatedPoints += 0 // Derrota
            updatedMatchesLost += 1
        }
        
        // Incrementar `matchesPlayed` siempre
        updatedMatchesPlayed += 1
        
        // Actualizar goles
        updatedGoalsScored += golesScored
        updatedGoalsAgainst += golesAgainst
        
        // Actualizar el Goal Difference
        updatedGoalDifference = updatedGoalsScored - updatedGoalsAgainst
        
        // Actualizar los valores en Firestore
        teamRef.updateData([
            "matchesPlayed": updatedMatchesPlayed,
            "goalsScored": updatedGoalsScored,
            "goalsAgainst": updatedGoalsAgainst,
            "goalDifference": updatedGoalDifference,
            "points": updatedPoints,
            "matchesDrawn": updatedMatchesDrawn,
            "matchesLost": updatedMatchesLost,
            "matchesWon": updatedMatchesWon
        ]) { error in
            if let error = error {
                print("Error al actualizar el equipo con ID \(teamId): \(error.localizedDescription)")
            } else {
                print("Equipo con ID \(teamId) actualizado con éxito.")
            }
        }
    }

    // Registrar Partido
    
    func registerMatch(partido: Partido) {
        let db = Firestore.firestore()
        
        do {
            let data = try Firestore.Encoder().encode(partido)
            let documentId = "clausura_\(partido.fecha)_\(partido.teamAId)_\(partido.teamBId)"
            db.collection("matches").document(documentId).setData(data) { error in
                if let error = error {
                    print("Error al registrar el partido con ID \(documentId): \(error.localizedDescription)")
                } else {
                    print("Partido registrado con éxito con ID \(documentId)")
                }
            }
        } catch {
            print("Error al codificar el partido: \(error)")
        }
    }
    
    func registerMultipleMatches(partidos: [Partido]) {
        let db = Firestore.firestore()
        
        for partido in partidos {
            do {
                let data = try Firestore.Encoder().encode(partido)
                let documentId = "clausura_\(partido.fecha)_\(partido.teamAId)_\(partido.teamBId)"
                db.collection("matches").document(documentId).setData(data) { error in
                    if let error = error {
                        print("Error al registrar el partido con ID \(documentId): \(error.localizedDescription)")
                    } else {
                        print("Partido registrado con éxito con ID \(documentId)")
                    }
                }
            } catch {
                print("Error al codificar el partido: \(error)")
            }
        }
    }
    
    func updateMultipleMatches(matches: [(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int)]) {
        for match in matches {
            updateLiveMatch(teamAId: match.teamAId, teamBId: match.teamBId, fecha: match.fecha, teamAScore: match.teamAScore, teamBScore: match.teamBScore)
        }
    }
        
    func actualizarTablaPosiciones() {
        let db = Firestore.firestore()
        
        db.collection("matches").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error al obtener los documentos: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var equipos = [String: [String: Any]]()

            for document in documents {
                let data = document.data()
                let teamAId = data["teamAId"] as? String ?? ""
                let teamBId = data["teamBId"] as? String ?? ""
                let golesTeamA = data["golesTeamA"] as? Int ?? 0
                let golesTeamB = data["golesTeamB"] as? Int ?? 0

                if equipos[teamAId] == nil {
                    equipos[teamAId] = [
                        "matchesPlayed": 0,
                        "matchesWon": 0,
                        "matchesDrawn": 0,
                        "matchesLost": 0,
                        "goalsScored": 0,
                        "goalsAgainst": 0,
                        "goalDifference": 0,
                        "points": 0
                    ]
                }
                if equipos[teamBId] == nil {
                    equipos[teamBId] = [
                        "matchesPlayed": 0,
                        "matchesWon": 0,
                        "matchesDrawn": 0,
                        "matchesLost": 0,
                        "goalsScored": 0,
                        "goalsAgainst": 0,
                        "goalDifference": 0,
                        "points": 0
                    ]
                }

                if data["estado"] as? String == "finalizado" {
                    var teamAStats = equipos[teamAId]!
                    var teamBStats = equipos[teamBId]!

                    // Actualizar partidos jugados
                    teamAStats["matchesPlayed"] = (teamAStats["matchesPlayed"] as? Int ?? 0) + 1
                    teamBStats["matchesPlayed"] = (teamBStats["matchesPlayed"] as? Int ?? 0) + 1

                    if golesTeamA > golesTeamB {
                        // Victoria de teamA
                        teamAStats["matchesWon"] = (teamAStats["matchesWon"] as? Int ?? 0) + 1
                        teamAStats["points"] = (teamAStats["points"] as? Int ?? 0) + 3
                        teamBStats["matchesLost"] = (teamBStats["matchesLost"] as? Int ?? 0) + 1
                    } else if golesTeamA < golesTeamB {
                        // Victoria de teamB
                        teamBStats["matchesWon"] = (teamBStats["matchesWon"] as? Int ?? 0) + 1
                        teamBStats["points"] = (teamBStats["points"] as? Int ?? 0) + 3
                        teamAStats["matchesLost"] = (teamAStats["matchesLost"] as? Int ?? 0) + 1
                    } else {
                        // Empate
                        teamAStats["matchesDrawn"] = (teamAStats["matchesDrawn"] as? Int ?? 0) + 1
                        teamBStats["matchesDrawn"] = (teamBStats["matchesDrawn"] as? Int ?? 0) + 1
                        teamAStats["points"] = (teamAStats["points"] as? Int ?? 0) + 1
                        teamBStats["points"] = (teamBStats["points"] as? Int ?? 0) + 1
                    }
                    
                    // Actualizar goles y diferencia de goles
                    teamAStats["goalsScored"] = (teamAStats["goalsScored"] as? Int ?? 0) + golesTeamA
                    teamAStats["goalsAgainst"] = (teamAStats["goalsAgainst"] as? Int ?? 0) + golesTeamB
                    teamBStats["goalsScored"] = (teamBStats["goalsScored"] as? Int ?? 0) + golesTeamB
                    teamBStats["goalsAgainst"] = (teamBStats["goalsAgainst"] as? Int ?? 0) + golesTeamA

                    // Calcular la diferencia de goles
                    teamAStats["goalDifference"] = ((teamAStats["goalsScored"] as? Int ?? 0) - (teamAStats["goalsAgainst"] as? Int ?? 0))
                    teamBStats["goalDifference"] = ((teamBStats["goalsScored"] as? Int ?? 0) - (teamBStats["goalsAgainst"] as? Int ?? 0))

                    // Guardar las actualizaciones en el diccionario principal
                    equipos[teamAId] = teamAStats
                    equipos[teamBId] = teamBStats
                }
            }

            let batch = db.batch()

            for (teamId, stats) in equipos {
                let equipoRef = db.collection("clausura").document(teamId)
                batch.updateData(stats, forDocument: equipoRef)
            }

            batch.commit { error in
                if let error = error {
                    print("Error al actualizar los equipos: \(error.localizedDescription)")
                } else {
                    print("Equipos actualizados correctamente.")
                }
            }
        }
    }

    func updateLiveMatch(teamAId: String, teamBId: String, fecha: String, teamAScore: Int, teamBScore: Int) {
        let db = Firestore.firestore()
        
        let torneo = "clausura"
        let matchId = "\(torneo)_\(fecha)_\(teamAId)_\(teamBId)"
        
        let matchRef = db.collection("matches").document(matchId)
        
        matchRef.updateData([
            "golesTeamA": teamAScore,
            "golesTeamB": teamBScore,
            "estado": "enJuego"
        ]) { error in
            if let error = error {
                print("Error updating match: \(error)")
            } else {
                print("Match updated successfully")
            }
        }
    }
    
    func finalizarPartido(teamAId: String, teamBId: String, fecha: String) {
        let db = Firestore.firestore()
        
        let torneo = "clausura"
        let matchId = "\(torneo)_\(fecha)_\(teamAId)_\(teamBId)"
        
        clearInitialStats(for: teamAId)
        clearInitialStats(for: teamBId)
        
        db.collection("matches").document(matchId).updateData([
            "estado": "finalizado"
        ]) { error in
            if let error = error {
                print("Error al finalizar el partido \(matchId): \(error.localizedDescription)")
            } else {
                print("Partido \(matchId) finalizado con éxito")
            }
        }
    }

    func finalizarTodosLosPartidos() {
        let db = Firestore.firestore()
        
        db.collection("matches").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error al obtener los documentos: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for document in documents {
                let matchId = document.documentID
                
                db.collection("matches").document(matchId).updateData([
                    "estado": "finalizado"
                ]) { error in
                    if let error = error {
                        print("Error al finalizar el partido \(matchId): \(error.localizedDescription)")
                    } else {
                        print("Partido \(matchId) finalizado con éxito")
                    }
                }
            }
        }
    }

    // Función para inicializar los equipos
    func initializeTeams() {
        
        let teams: [(String, String, String, String)] = [
            ("ali", "Alianza Lima", "Lima", "Alejandro Villanueva"),
            ("uni", "Universitario", "Lima", "Monumental"),
            ("cri", "Sporting Cristal", "Lima", "Alberto Gallardo"),
            ("cie", "Cienciano", "Cuzco", "Inca Garcilazo de la Vega"),
            ("cus", "Cusco FC", "Cuzco", "Inca Garcilazo de la Vega"),
            ("adt", "ADT", "Tarma", "Unión Tarma"),
            ("atl", "Alianza Atlético", "Sullana", "Campeones del 36"),
            ("mel", "Melgar", "Arequipa", "Monumental de la UNSA"),
            ("gra", "Atlético Grau", "Piura", "Campeones del 36"),
            ("gar", "Deportivo Garcilaso", "Cusco", "Inca Garcilazo de la Vega"),
            ("sba", "Sport Boys", "Callao", "Miguel Grau"),
            ("cha", "Chankas CYC", "Andahuaylas", "Los Chankas"),
            ("utc", "UTC Cajamarca", "Cajamarca", "Municipal Germán Contreras Jara"),
            ("hua", "Sport Huancayo", "Huancayo", "IPD Huancayo"),
            ("com", "Unión Comercio", "Tarapoto", "Carlos Vidaurre Garcia"),
            ("man", "Carlos Mannucci", "Trujillo", "Mansiche"),
            ("val", "César Vallejo", "Trujillo", "Mansiche"),
            ("cou", "Comerciantes Unidos", "Cutervo", "Municipal Germán Contreras Jara")
        ]
        
        for team in teams {
            let (id, name, city, stadium) = team
            addTeamDetails(id: id, name: name, city: city, stadium: stadium)
        }
    }
    
    private func addTeamDetails(id: String, name: String, city: String, stadium: String) {
        
        let db = Firestore.firestore()
        let aperturaRef = db.collection("equipos")
        
        aperturaRef.document(id).setData([
            "name": name,
            "city": city,
            "stadium": stadium
        ]) { error in
            if let error = error {
                print("Error registrando detalles del equipo: \(error)")
            } else {
                print("¡Detalles del equipo registrados con éxito!")
            }
        }
    }

    func cloneCollection(from originalCollection: CollectionReference, to newCollection: CollectionReference) {
        
//        let db = Firestore.firestore()
//        let originalCollection = db.collection("originalData")
//        let newCollection = db.collection("clonedData")
//        cloneCollection(from: originalCollection, to: newCollection)
        
        originalCollection.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    newCollection.document(document.documentID).setData(data) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(document.documentID)")
                        }
                    }
                }
            }
        }
    }
}

