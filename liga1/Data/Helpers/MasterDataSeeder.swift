//
//  MasterDataSeeder.swift
//  liga1
//
//  TEMPORAL — Ingesta única de datos maestros a Firestore (Fase 0).
//
//  Puebla tres colecciones nuevas que necesitan los módulos "Sabor Local"
//  (estadios/árbitros) y "Comunidad" (base de equipos):
//    • equipos/{code}     → metadata de club (merge: NO pisa campos de stats)
//    • stadiums/{slug}     → nombre, ciudad, altitud (msnm), lat/lng, capacidad
//    • referees/{slug}     → nombre, federación, nacionalidad
//
//  Fuente de datos: tabla "Equipos participantes" y tablas de resultados de
//  https://es.wikipedia.org/wiki/Torneo_Clausura_2026_(Perú)
//  Altitud y coordenadas: datos geográficos públicos, precisión a nivel de
//  ciudad (suficiente para clima y para mostrar el "factor altura").
//
//  Uso:
//   1. Llamar `MasterDataSeeder.runIfNeeded(logger:)` una vez desde
//      `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.
//   2. Abrir la app una vez con red. Corre en background, se autobloquea con
//      el flag `seed_master_data_v1` en UserDefaults.
//   3. **Eliminar este archivo y la llamada en AppDelegate después de ejecutarlo.**
//
//  Para re-ejecutar: borrar la clave `seed_master_data_v1` de UserDefaults
//  (o reinstalar) y subir la versión del flag.
//

import Foundation
import FirebaseFirestore

enum MasterDataSeeder {

    private static let didRunKey = "seed_master_data_v1"

    // MARK: - Ejecución

    static func runIfNeeded(logger: LoggerProtocol) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: didRunKey) else { return }

        Task {
            do {
                let count = try await run()
                defaults.set(true, forKey: didRunKey)
                logger.info("MasterDataSeeder: OK — \(count) documentos (equipos + stadiums + referees).")
            } catch {
                logger.error("MasterDataSeeder: falló, se reintentará en el próximo arranque", error: error)
            }
        }
    }

    @discardableResult
    private static func run() async throws -> Int {
        let db = FirestoreManager.shared.db
        let ts = FieldValue.serverTimestamp()
        var writes: [(ref: DocumentReference, data: [String: Any])] = []

        // --- stadiums/{slug} ---
        for s in stadiums {
            var data: [String: Any] = [
                "name": s.name,
                "city": s.city,
                "region": s.region,
                "altitudeMsnm": s.altitudeMsnm,
                "lat": s.lat,
                "lng": s.lng,
                "capacity": s.capacity,
                "surface": "grass",
                "homeTeamCodes": s.homeTeamCodes,
                "updatedAt": ts
            ]
            if let dato = s.dato { data["dato"] = dato }
            writes.append((db.collection("stadiums").document(slug(s.name)), data))
        }

        // --- equipos/{code} (merge: preserva matchesPlayed/points/etc. si existen) ---
        let stadiumByTeam = stadiumCodeByTeam()
        for t in teams {
            guard let stadiumCode = stadiumByTeam[t.code] else {
                throw NSError(domain: "MasterDataSeeder", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Sin estadio para \(t.code)"])
            }
            writes.append((db.collection("equipos").document(t.code), [
                "name": t.name,
                "officialName": t.officialName,
                "city": t.city,
                "region": t.region,
                "coach": ["name": t.coachName, "nat": t.coachNat],
                "stadiumCode": stadiumCode,
                "updatedAt": ts
            ]))
        }

        // --- referees/{slug} ---
        for name in refereeNames {
            writes.append((db.collection("referees").document(slug(name)), [
                "fullName": name,
                "federation": "FPF",
                "nationality": "PER",
                "source": "wikipedia-clausura-2026",
                "updatedAt": ts
            ]))
        }

        // --- equipos/{code}/players/{slug} ---
        var seen = Set<String>()
        for p in players {
            let id = slug(p.fullName)
            guard seen.insert("\(p.teamCode)/\(id)").inserted else { continue }
            writes.append((
                db.collection("equipos").document(p.teamCode).collection("players").document(id),
                [
                    "fullName": p.fullName,
                    "shortName": Self.shortName(p.fullName),
                    "number": p.number.map { $0 as Any } ?? NSNull(),
                    "position": p.position,
                    "nationality": p.nat,
                    "photoURL": NSNull(),
                    "status": "active",
                    "updatedAt": ts
                ]
            ))
        }

        // Commit en lotes (límite de Firestore: 500 ops por batch).
        let chunkSize = 450
        for start in stride(from: 0, to: writes.count, by: chunkSize) {
            let batch = db.batch()
            for w in writes[start..<min(start + chunkSize, writes.count)] {
                batch.setData(w.data, forDocument: w.ref, merge: true)
            }
            try await batch.commit()
        }
        return writes.count
    }

    /// Último token del nombre como apellido corto para la UI compacta.
    static func shortName(_ fullName: String) -> String {
        fullName.split(separator: " ").last.map(String.init) ?? fullName
    }

    // MARK: - Slug determinista (IDs de estadio y árbitro)

    /// minúsculas · sin diacríticos · `[^a-z0-9]` → "-" · colapsa y recorta "-".
    static func slug(_ input: String) -> String {
        let folded = input.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX"))
        let lowered = folded.lowercased()
        var out = ""
        var lastWasDash = false
        for scalar in lowered.unicodeScalars {
            if (scalar >= "a" && scalar <= "z") || (scalar >= "0" && scalar <= "9") {
                out.unicodeScalars.append(scalar)
                lastWasDash = false
            } else if !lastWasDash {
                out.append("-")
                lastWasDash = true
            }
        }
        return out.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func stadiumCodeByTeam() -> [String: String] {
        var map: [String: String] = [:]
        for s in stadiums {
            let code = slug(s.name)
            for team in s.homeTeamCodes { map[team] = code }
        }
        return map
    }

    // MARK: - Datos

    private struct TeamSeed {
        let code, name, officialName, city, region, coachName, coachNat: String
    }

    private struct StadiumSeed {
        let name, city, region: String
        let altitudeMsnm, capacity: Int
        let lat, lng: Double
        let homeTeamCodes: [String]
        let dato: String?
    }

    /// 18 clubes. `code` coincide con `EquipoPeruano.rawValue`.
    private static let teams: [TeamSeed] = [
        .init(code: "adt", name: "ADT", officialName: "Asociación Deportiva Tarma", city: "Tarma", region: "Junín", coachName: "Francisco Usúcar", coachNat: "URU"),
        .init(code: "atl", name: "Alianza Atlético", officialName: "Club Alianza Atlético Sullana", city: "Sullana", region: "Piura", coachName: "Federico Urciuoli", coachNat: "ARG"),
        .init(code: "ali", name: "Alianza Lima", officialName: "Club Alianza Lima", city: "Lima", region: "Lima", coachName: "Pablo Guede", coachNat: "ARG"),
        .init(code: "gra", name: "Atlético Grau", officialName: "Club Atlético Grau", city: "Piura", region: "Piura", coachName: "Gerardo Ameli", coachNat: "ARG"),
        .init(code: "cie", name: "Cienciano", officialName: "Club Cienciano", city: "Cusco", region: "Cusco", coachName: "Horacio Melgarejo", coachNat: "ARG"),
        .init(code: "cou", name: "Comerciantes Unidos", officialName: "Club Deportivo Comerciantes Unidos", city: "Cutervo", region: "Cajamarca", coachName: "Daniel Morales", coachNat: "PER"),
        .init(code: "cus", name: "Cusco FC", officialName: "Cusco Fútbol Club", city: "Cusco", region: "Cusco", coachName: "Javier Rabanal", coachNat: "ESP"),
        .init(code: "gar", name: "Deportivo Garcilaso", officialName: "Club Deportivo Garcilaso", city: "Cusco", region: "Cusco", coachName: "Sebastián Domínguez", coachNat: "ARG"),
        .init(code: "moq", name: "Deportivo Moquegua", officialName: "Club Deportivo Moquegua", city: "Moquegua", region: "Moquegua", coachName: "Jaime Serna", coachNat: "PER"),
        .init(code: "mel", name: "Melgar", officialName: "Foot Ball Club Melgar", city: "Arequipa", region: "Arequipa", coachName: "Miguel Rondelli", coachNat: "ARG"),
        .init(code: "caj", name: "FC Cajamarca", officialName: "Fútbol Club Cajamarca", city: "Cajamarca", region: "Cajamarca", coachName: "Celso Ayala", coachNat: "PAR"),
        .init(code: "jpa", name: "Juan Pablo II College", officialName: "Asociación Club Deportivo Juan Pablo II College", city: "Chongoyape", region: "Lambayeque", coachName: "Marcelo Zuleta", coachNat: "ARG"),
        .init(code: "cha", name: "Los Chankas", officialName: "Club Deportivo Los Chankas", city: "Andahuaylas", region: "Apurímac", coachName: "Walter Paolella", coachNat: "ARG"),
        .init(code: "sba", name: "Sport Boys", officialName: "Sport Boys Association", city: "Callao", region: "Callao", coachName: "Carlos Desio", coachNat: "ARG"),
        .init(code: "hua", name: "Sport Huancayo", officialName: "Club Sport Huancayo", city: "Huancayo", region: "Junín", coachName: "Richard Pellejero", coachNat: "URU"),
        .init(code: "cri", name: "Sporting Cristal", officialName: "Club Sporting Cristal", city: "Lima", region: "Lima", coachName: "Roberto Mosquera", coachNat: "PER"),
        .init(code: "uni", name: "Universitario", officialName: "Club Universitario de Deportes", city: "Lima", region: "Lima", coachName: "Héctor Cúper", coachNat: "ARG"),
        .init(code: "utc", name: "UTC Cajamarca", officialName: "Club Universidad Técnica de Cajamarca", city: "Cajamarca", region: "Cajamarca", coachName: "Carlos Bustos", coachNat: "ARG")
    ]

    /// 15 estadios (Cusco y Cajamarca compartidos). Altitud/coords aprox. a nivel de ciudad.
    private static let stadiums: [StadiumSeed] = [
        .init(name: "Estadio Unión Tarma", city: "Tarma", region: "Junín", altitudeMsnm: 3053, capacity: 5000, lat: -11.4189, lng: -75.6903, homeTeamCodes: ["adt"], dato: "A más de 3000 msnm: el visitante suele acusar la altura en el complemento."),
        .init(name: "Estadio Campeones del 36", city: "Sullana", region: "Piura", altitudeMsnm: 60, capacity: 12000, lat: -4.9039, lng: -80.6853, homeTeamCodes: ["atl"], dato: nil),
        .init(name: "Estadio Alejandro Villanueva", city: "Lima", region: "Lima", altitudeMsnm: 120, capacity: 34000, lat: -12.07, lng: -77.023, homeTeamCodes: ["ali"], dato: "Matute: una de las canchas más ruidosas del país."),
        .init(name: "Estadio Municipal Ambrosio Maco Arroyo", city: "Sullana", region: "Piura", altitudeMsnm: 60, capacity: 5000, lat: -4.883, lng: -80.69, homeTeamCodes: ["gra"], dato: nil),
        .init(name: "Estadio Inca Garcilaso de la Vega", city: "Cusco", region: "Cusco", altitudeMsnm: 3399, capacity: 42056, lat: -13.525, lng: -71.954, homeTeamCodes: ["cie", "cus", "gar"], dato: "A 3400 msnm: histórico fortín para los equipos cusqueños."),
        .init(name: "Estadio Juan Maldonado Gamarra", city: "Cutervo", region: "Cajamarca", altitudeMsnm: 2637, capacity: 8000, lat: -6.379, lng: -78.818, homeTeamCodes: ["cou"], dato: nil),
        .init(name: "Estadio 25 de Noviembre", city: "Moquegua", region: "Moquegua", altitudeMsnm: 1410, capacity: 21000, lat: -17.193, lng: -70.935, homeTeamCodes: ["moq"], dato: nil),
        .init(name: "Estadio Arequipa", city: "Arequipa", region: "Arequipa", altitudeMsnm: 2320, capacity: 20000, lat: -16.409, lng: -71.5375, homeTeamCodes: ["mel"], dato: "Arequipa a 2300 msnm: Melgar se hace fuerte de local."),
        .init(name: "Estadio Héroes de San Ramón", city: "Cajamarca", region: "Cajamarca", altitudeMsnm: 2720, capacity: 18000, lat: -7.156, lng: -78.506, homeTeamCodes: ["caj", "utc"], dato: nil),
        .init(name: "Estadio Complejo Deportivo Juan Pablo II", city: "Chongoyape", region: "Lambayeque", altitudeMsnm: 230, capacity: 3000, lat: -6.639, lng: -79.389, homeTeamCodes: ["jpa"], dato: nil),
        .init(name: "Estadio Los Chankas", city: "Andahuaylas", region: "Apurímac", altitudeMsnm: 2926, capacity: 8000, lat: -13.656, lng: -73.388, homeTeamCodes: ["cha"], dato: nil),
        .init(name: "Estadio Miguel Grau", city: "Callao", region: "Callao", altitudeMsnm: 10, capacity: 17000, lat: -12.057, lng: -77.129, homeTeamCodes: ["sba"], dato: nil),
        .init(name: "Estadio Huancayo", city: "Huancayo", region: "Junín", altitudeMsnm: 3271, capacity: 20000, lat: -12.068, lng: -75.21, homeTeamCodes: ["hua"], dato: "IPD de Huancayo, 3271 msnm: otra plaza de altura del centro del país."),
        .init(name: "Estadio Alberto Gallardo", city: "Lima", region: "Lima", altitudeMsnm: 110, capacity: 18000, lat: -12.073, lng: -77.017, homeTeamCodes: ["cri"], dato: nil),
        .init(name: "Estadio Monumental U", city: "Ate", region: "Lima", altitudeMsnm: 355, capacity: 80093, lat: -12.0447, lng: -76.9394, homeTeamCodes: ["uni"], dato: "El estadio más grande del Perú.")
    ]

    /// Árbitros observados en las tablas de resultados del Clausura 2026 (todos FPF).
    private static let refereeNames: [String] = [
        "Jesús Cartagena", "Bruno Pérez", "Kevin Ortega", "Jordi Espinoza",
        "Augusto Menéndez", "Michael Espinoza", "Joel Alarcón", "Edwin Ordóñez",
        "Micke Palomino", "Sebastián Lozano", "Daniel Ureta", "Walter Guadalupe",
        "Junior Rivera", "David Huamán", "Julio Quiroz", "Rudy Méndez",
        "James Huamaní", "Cristhian Santos", "Brandon Torrecilla", "Lennin Montalbán",
        "Alexander Blas", "Maykol Farromeque"
    ]
}
