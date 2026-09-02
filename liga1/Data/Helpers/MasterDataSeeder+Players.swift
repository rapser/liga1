//
//  MasterDataSeeder+Players.swift
//  liga1
//
//  TEMPORAL — Planteles 2026 para el seeder de datos maestros (Fase 0).
//
//  Fuente: sección "Plantel/Plantilla 2026" del artículo de cada club en
//  Wikipedia en español (18 clubes). Compilado y revisado como literales.
//  Puede haber desfases de mercado de pases: es un punto de partida, se
//  corrige después. `number` puede ser nil (jugador sin dorsal fijo).
//
//  position: GK · DEF · MID · FWD   ·   nat: código de 3 letras.
//

import Foundation

extension MasterDataSeeder {

    struct PlayerSeed {
        let teamCode: String
        let fullName: String
        let number: Int?
        let position: String
        let nat: String
    }

    /// Azúcar para mantener las filas en una línea.
    private static func p(_ team: String, _ name: String, _ num: Int?, _ pos: String, _ nat: String) -> PlayerSeed {
        PlayerSeed(teamCode: team, fullName: name, number: num, position: pos, nat: nat)
    }

    static let players: [PlayerSeed] = [
        // MARK: adt — ADT (Tarma)
        p("adt", "Juan David Valencia", 30, "GK", "COL"), p("adt", "Carlos Solís Ugarte", 33, "GK", "PER"), p("adt", "Enzo Mori", nil, "GK", "PER"),
        p("adt", "Ronny Biojó", 4, "DEF", "ECU"), p("adt", "Carlos Cabello", 14, "DEF", "PER"), p("adt", "Arthur Gutiérrez", 20, "DEF", "PER"),
        p("adt", "John Narváez", 23, "DEF", "ECU"), p("adt", "Jhair Soto", 28, "DEF", "PER"), p("adt", "Jerry Navarro", 31, "DEF", "PER"), p("adt", "Joao Acosta", 73, "DEF", "PER"),
        p("adt", "Jair Reyes", 2, "MID", "PER"), p("adt", "Jhon Vega", 5, "MID", "PER"), p("adt", "Ángel Ojeda", 6, "MID", "PER"), p("adt", "Joao Rojas", 7, "MID", "ECU"),
        p("adt", "Jordan Guivin", 8, "MID", "PER"), p("adt", "Víctor Cedrón", 10, "MID", "PER"), p("adt", "Josue Alvino", 15, "MID", "PER"), p("adt", "Luis Pérez", 16, "MID", "COL"),
        p("adt", "Aarón Carnero", 19, "MID", "PER"), p("adt", "Sinclair García", 25, "MID", "PER"), p("adt", "Alexander Hidalgo", 27, "MID", "PER"), p("adt", "Emerson García", 29, "MID", "PER"),
        p("adt", "Hernán Rengifo", 9, "FWD", "PER"), p("adt", "Anthony Cubas", 11, "FWD", "PER"), p("adt", "Hideyoshi Arakaki", 17, "FWD", "PER"), p("adt", "Aylton Mazzo", 18, "FWD", "PER"),
        p("adt", "Luis Benites", 21, "FWD", "PER"), p("adt", "Aldair Rodríguez", 22, "FWD", "PER"), p("adt", "Jhojan Garcilazo", 26, "FWD", "PER"), p("adt", "Jonatan Bauman", 32, "FWD", "ARG"), p("adt", "Nicolás Rengifo", 37, "FWD", "PER"),

        // MARK: atl — Alianza Atlético (Sullana)
        p("atl", "Eder Hermoza", 1, "GK", "PER"), p("atl", "Jesús Rossi", 28, "GK", "PER"), p("atl", "Daniel Prieto", 95, "GK", "PER"),
        p("atl", "Román Suárez", 2, "DEF", "ARG"), p("atl", "José Carlos Villegas", 4, "DEF", "ARG"), p("atl", "José Luján", 6, "DEF", "PER"), p("atl", "Luiggi Alburqueque", 14, "DEF", "PER"),
        p("atl", "Jesús Mendieta", 19, "DEF", "PER"), p("atl", "Erick Perleche", 21, "DEF", "PER"), p("atl", "Anthony Gordillo", 24, "DEF", "PER"), p("atl", "Williams Guzmán", 25, "DEF", "PER"), p("atl", "Juan Jesús Quiñones", 40, "DEF", "PER"),
        p("atl", "Germán Gastón Díaz", 10, "MID", "ARG"), p("atl", "Hernán Lupu", 15, "MID", "PER"), p("atl", "Stefano Fernández", 16, "MID", "PER"), p("atl", "Jimmy Pérez", 20, "MID", "PER"),
        p("atl", "Jorge del Castillo", 22, "MID", "PER"), p("atl", "Elian Ariel Muñoz", 23, "MID", "ARG"), p("atl", "Juan David Delgado", 37, "MID", "PER"),
        p("atl", "Franco Coronel", 7, "FWD", "ARG"), p("atl", "Franchesco Flores", 8, "FWD", "PER"), p("atl", "Valentín Robaldo", 9, "FWD", "ARG"), p("atl", "Guillermo Larios", 11, "FWD", "CHI"),
        p("atl", "Cristian Penilla", 17, "FWD", "ECU"), p("atl", "Cristhian Valladolid", 77, "FWD", "PER"), p("atl", "Mariano Barreda", 99, "FWD", "PER"),

        // MARK: ali — Alianza Lima
        p("ali", "Alejandro Duarte", 1, "GK", "PER"), p("ali", "Ángel de la Cruz", 12, "GK", "PER"), p("ali", "Fabrisio Mesías", 33, "GK", "PER"),
        p("ali", "Nicolás Díaz Huincales", 2, "DEF", "CHI"), p("ali", "Mateo Antoni", 3, "DEF", "URU"), p("ali", "Gianfranco Chávez", 4, "DEF", "PER"), p("ali", "Renzo Garcés", 6, "DEF", "PER"),
        p("ali", "Marco Huamán", 13, "DEF", "PER"), p("ali", "D'Alessandro Montenegro", 14, "DEF", "PER"), p("ali", "Luis Advíncula", 17, "DEF", "PER"), p("ali", "Cristian Carbajal", 31, "DEF", "PER"),
        p("ali", "Jhoao Velásquez", 35, "DEF", "PER"), p("ali", "Rait Alarcón", nil, "DEF", "PER"), p("ali", "Josué Estrada", 77, "DEF", "PER"),
        p("ali", "Esteban Pavez", 5, "MID", "CHI"), p("ali", "Fernando Gaibor", 7, "MID", "ECU"), p("ali", "Jesús Castillo Peña", 15, "MID", "PER"), p("ali", "Alessandro Burlamaqui", 18, "MID", "PER"),
        p("ali", "Jairo Vélez", 20, "MID", "PER"), p("ali", "Piero Cari", 21, "MID", "PER"), p("ali", "Cristian Neira", 22, "MID", "PER"), p("ali", "Pedro Aquino Sánchez", 55, "MID", "PER"),
        p("ali", "Eryc Castillo", 8, "FWD", "ECU"), p("ali", "Luis Ramos Leiva", 9, "FWD", "PER"), p("ali", "Alan Cantero", 11, "FWD", "ARG"), p("ali", "Gaspar Gentile", 25, "FWD", "PER"),
        p("ali", "Kevin Quevedo", 27, "FWD", "PER"), p("ali", "Geray Motta", 30, "FWD", "PER"), p("ali", "Paolo Guerrero", 34, "FWD", "PER"), p("ali", "Federico Girotti", 99, "FWD", "ARG"),

        // MARK: gra — Atlético Grau (Piura)
        p("gra", "Patricio Álvarez", 1, "GK", "PER"), p("gra", "Aarom Fuentes", 12, "GK", "PER"), p("gra", "Breyner Vilela", 23, "GK", "PER"), p("gra", "Aamet Calderón", 33, "GK", "PER"),
        p("gra", "Christian Vásquez", nil, "DEF", "PER"), p("gra", "Lucas Acevedo", 2, "DEF", "ARG"), p("gra", "Ignacio Tapia", 3, "DEF", "CHI"), p("gra", "Elsar Rodas", 6, "DEF", "PER"),
        p("gra", "José Ataupillco", 16, "DEF", "PER"), p("gra", "Gabriel Alfaro", 25, "DEF", "PER"), p("gra", "Arnold Flores", 26, "DEF", "PER"), p("gra", "Rodrigo Tapia", 27, "DEF", "ARG"), p("gra", "Santiago Torres González", 32, "DEF", "ARG"),
        p("gra", "Rafael Guarderas", 5, "MID", "PER"), p("gra", "Diego Fabián Barreto", 7, "MID", "PAR"), p("gra", "Paulo de la Cruz", 10, "MID", "PER"), p("gra", "Freddy Oncoy", 13, "MID", "PER"),
        p("gra", "Aldair Vásquez Garcés", 20, "MID", "PER"), p("gra", "Eslyn Correa", 21, "MID", "PER"), p("gra", "Cristian Neira", 22, "MID", "PER"), p("gra", "Emiliano Franco", 29, "MID", "ARG"), p("gra", "Adrián de la Cruz", 66, "MID", "PER"),
        p("gra", "Raúl Ruidíaz", 9, "FWD", "PER"), p("gra", "Nicolás Delgadillo", 11, "FWD", "ARG"), p("gra", "Henri Espinoza", 17, "FWD", "PER"), p("gra", "Isaac Camargo", 19, "FWD", "COL"), p("gra", "Yamir Ruidíaz", 24, "FWD", "PER"),

        // MARK: cie — Cienciano (Cusco)
        p("cie", "Gonzalo Falcón", 1, "GK", "URU"), p("cie", "Jean Franco Roncal", 30, "GK", "PER"), p("cie", "Ítalo Espinoza", 31, "GK", "PER"),
        p("cie", "Kevin Becerra", 3, "DEF", "ECU"), p("cie", "Maximiliano Amondarain", 4, "DEF", "URU"), p("cie", "Claudio Núñez", 13, "DEF", "PAR"), p("cie", "Sebastián Cavero", 14, "DEF", "PER"),
        p("cie", "Marcos Martinich", 16, "DEF", "ARG"), p("cie", "Rotceh Aguilar", 26, "DEF", "PER"), p("cie", "Alonso Yovera", 27, "DEF", "PER"), p("cie", "Renzo Salazar", nil, "DEF", "PER"),
        p("cie", "Santiago Arias", 5, "MID", "URU"), p("cie", "Gonzalo Aguirre", 8, "MID", "ARG"), p("cie", "Ademar Robles", 29, "MID", "PER"), p("cie", "Álvaro Rojas", 37, "MID", "PER"),
        p("cie", "Henry Caparó", 39, "MID", "PER"), p("cie", "Gerson Barreto", 88, "MID", "PER"),
        p("cie", "Cristian Souza", 7, "FWD", "URU"), p("cie", "Juan Romagnoli", 9, "FWD", "ARG"), p("cie", "Alejandro Hohberg", 10, "FWD", "PER"), p("cie", "Neri Bandiera", 11, "FWD", "ARG"),
        p("cie", "Ray Sandoval", 17, "FWD", "PER"), p("cie", "Matías Succar", 19, "FWD", "PER"), p("cie", "Carlos Garcés", 21, "FWD", "ECU"), p("cie", "Nadhir Colunga", 99, "FWD", "PER"),

        // MARK: cou — Comerciantes Unidos (Cutervo)
        p("cou", "Juan Cubas", 1, "GK", "PER"), p("cou", "Matías Córdova", 17, "GK", "PER"), p("cou", "José Pablo Charún Valdez", 99, "GK", "PER"),
        p("cou", "Juan José Rodríguez", 6, "DEF", "URU"), p("cou", "Alexis Cossio", 15, "DEF", "PER"), p("cou", "Fabio Renato Rojas", 16, "DEF", "PER"), p("cou", "Daniel Lino", 19, "DEF", "BOL"),
        p("cou", "Piero Guzmán", 30, "DEF", "PER"), p("cou", "Miguel Hilario", 33, "DEF", "PER"), p("cou", "Flavio Alcedo", 40, "DEF", "PER"),
        p("cou", "Alexis Arias", 4, "MID", "PER"), p("cou", "Mathías Carpio", 10, "MID", "PER"), p("cou", "Thiago Alessandro Salinas Melgar", 14, "MID", "PER"), p("cou", "Agustín Rodríguez", 18, "MID", "URU"),
        p("cou", "José Parodi Colunga", 20, "MID", "PER"), p("cou", "Rodrigo Vilca", 25, "MID", "PER"),
        p("cou", "Wilter Ayoví", 8, "FWD", "ECU"), p("cou", "Matías Sen", 9, "FWD", "ARG"), p("cou", "Josuee Jesús Herrera Taber", 11, "FWD", "PER"), p("cou", "Maxi Pérez", 13, "FWD", "URU"),
        p("cou", "Fabrizio Cubas", 21, "FWD", "PER"), p("cou", "Óscar Pinto", 28, "FWD", "PER"),

        // MARK: cus — Cusco FC
        p("cus", "Rodolfo Anderson", 1, "GK", "PER"), p("cus", "Andy Vidal", 13, "GK", "PER"), p("cus", "Pedro Díaz", 28, "GK", "PER"), p("cus", "Alessandro Cavagna", nil, "GK", "PER"),
        p("cus", "Carlos Gamarra", 2, "DEF", "PER"), p("cus", "Álex Custodio", 4, "DEF", "VEN"), p("cus", "Álvaro Ampuero", 6, "DEF", "PER"), p("cus", "Aldair Fuentes", 8, "DEF", "PER"),
        p("cus", "José Bolívar", 15, "DEF", "PER"), p("cus", "José Zevallos", 21, "DEF", "PER"), p("cus", "Marlon Ruidías", 24, "DEF", "PER"), p("cus", "Julinho Astudillo", 32, "DEF", "PER"), p("cus", "Gu-Rum Choi", 37, "DEF", "KOR"),
        p("cus", "Miguel Aucca", 5, "MID", "PER"), p("cus", "Iván Colman", 10, "MID", "ARG"), p("cus", "Carlo Diez", 14, "MID", "PER"), p("cus", "Oswaldo Valenzuela", 16, "MID", "PER"),
        p("cus", "Lucas Colitto", 22, "MID", "ARG"), p("cus", "Gabriel Carabajal", 27, "MID", "ARG"), p("cus", "Sergio Quillahuaman", 30, "MID", "PER"), p("cus", "Diego Soto", 88, "MID", "PER"),
        p("cus", "José Manzaneda", 7, "FWD", "PER"), p("cus", "Facundo Callejo", 9, "FWD", "ARG"), p("cus", "Juan Tévez", 11, "FWD", "ARG"), p("cus", "José Alí", 17, "FWD", "PER"),
        p("cus", "Nicolás Silva", 26, "FWD", "ARG"), p("cus", "Joel Herrera", 77, "FWD", "PER"),

        // MARK: gar — Deportivo Garcilaso (Cusco)
        p("gar", "Patrick Zubczuk", 1, "GK", "PER"), p("gar", "Mallki Marmanillo", 12, "GK", "PER"), p("gar", "Juniors Barbieri", 31, "GK", "PER"),
        p("gar", "Aldair Salazar", 2, "DEF", "PER"), p("gar", "Agustín Gómez", 19, "DEF", "ARG"), p("gar", "Horacio Benincasa", 13, "DEF", "ARG"), p("gar", "Orlando Nuñez", 16, "DEF", "PER"),
        p("gar", "Jefferson Portales", 22, "DEF", "PER"), p("gar", "Xavi Moreno", 23, "DEF", "PER"), p("gar", "Samir Villacorta", 33, "DEF", "PER"), p("gar", "Erick Canales", 55, "DEF", "PER"),
        p("gar", "Inti Garrafa", 6, "MID", "PER"), p("gar", "Agustín González", 8, "MID", "URU"), p("gar", "Kevin Sandoval", 10, "MID", "PER"), p("gar", "Claudio Torrejón", 14, "MID", "USA"),
        p("gar", "Carlos Ramos", 18, "MID", "VEN"), p("gar", "Adrián Ascues", 27, "MID", "PER"), p("gar", "Joao Mendoza", 35, "MID", "PER"),
        p("gar", "José Luis Sinisterra", 7, "FWD", "COL"), p("gar", "Paulo Rodríguez", 9, "FWD", "PER"), p("gar", "Francisco Arancibia", 11, "FWD", "CHI"), p("gar", "Sharif Ramírez", 17, "FWD", "PER"),
        p("gar", "James Morales", 20, "FWD", "PER"), p("gar", "Christopher Olivares", 24, "FWD", "PER"), p("gar", "Agustín Graneros", 29, "FWD", "ARG"), p("gar", "Beto da Silva", 30, "FWD", "PER"), p("gar", "Bryan Yupanqui", 34, "FWD", "PER"),

        // MARK: moq — Deportivo Moquegua
        p("moq", "Carlos Grados", 1, "GK", "PER"), p("moq", "William Falcón", 12, "GK", "PER"), p("moq", "Renzo Figueroa", 29, "GK", "PER"), p("moq", "Thiago Bedoya", nil, "GK", "PER"),
        p("moq", "Cristian Enciso", 3, "DEF", "PAR"), p("moq", "Aldair Perleche", 4, "DEF", "PER"), p("moq", "Brayan Rivera", 5, "DEF", "PER"), p("moq", "Jimmy Jiménez", 6, "DEF", "PER"),
        p("moq", "Juan Diego Lojas", 13, "DEF", "PER"), p("moq", "Nicolás Amasifuén", 15, "DEF", "PER"), p("moq", "Eros Montenegro", 22, "DEF", "PER"), p("moq", "Kevin Moreno Alzamora", 24, "DEF", "PER"),
        p("moq", "José Luis Granda Bravo", 30, "DEF", "PER"), p("moq", "Mathias Panizo", nil, "DEF", "PER"),
        p("moq", "Cristian Adrián Mejía", 8, "MID", "PER"), p("moq", "Derlis Nicolás Chávez", 10, "MID", "PAR"), p("moq", "Claudio Ramírez", 14, "MID", "PER"), p("moq", "Diego Antonio Ramírez", 20, "MID", "PER"),
        p("moq", "Ricardo Chipao", 25, "MID", "PER"), p("moq", "José López Quintanilla", 28, "MID", "PER"),
        p("moq", "Édgar Lastre", 7, "FWD", "ECU"), p("moq", "Marcello Negrón", 9, "FWD", "PER"), p("moq", "Bryan Angulo", 11, "FWD", "ECU"), p("moq", "Allonso Dávila", 16, "FWD", "PER"),
        p("moq", "Yorman Zapata", 17, "FWD", "COL"), p("moq", "Kevin Ruiz", 77, "FWD", "PER"), p("moq", "Jefferson Collazos", 90, "FWD", "COL"), p("moq", "Juan Vilela", nil, "FWD", "PER"),

        // MARK: mel — Melgar (Arequipa)
        p("mel", "Ricardo Farro", 1, "GK", "PER"), p("mel", "Carlos Cáceda", 12, "GK", "PER"), p("mel", "Jorge Cabezudo", 21, "GK", "PER"), p("mel", "Facundo de la Cruz", 31, "GK", "PER"),
        p("mel", "Daniel Meneses", 2, "DEF", "PER"), p("mel", "Leonel González", 3, "DEF", "ARG"), p("mel", "Diego Pablo", nil, "DEF", "PER"), p("mel", "Alec Deneumostier", 5, "DEF", "PER"),
        p("mel", "Juan Escobar Chena", 23, "DEF", "PAR"), p("mel", "Nelson Cabanillas", 27, "DEF", "PER"), p("mel", "Matías Lazo", 33, "DEF", "PER"), p("mel", "Ángel Obando Campos", 38, "DEF", "PER"),
        p("mel", "Ian Arróspide", 42, "DEF", "PER"), p("mel", "Jesús Alcántar", 90, "DEF", "MEX"), p("mel", "Juan Ayqque", nil, "DEF", "PER"), p("mel", "Juan Muñoz Salazar", nil, "DEF", "PER"),
        p("mel", "Nicolás Quagliata", 10, "MID", "URU"), p("mel", "Gian García", 20, "MID", "PER"), p("mel", "Walter Tandazo", 24, "MID", "PER"), p("mel", "Kevin Minda", 25, "MID", "ECU"),
        p("mel", "Marcos Portillo", 26, "MID", "ARG"), p("mel", "José Ronald Rodríguez", 28, "MID", "PER"), p("mel", "Andersson Pumacajia", 29, "MID", "PER"), p("mel", "Patricio Núñez", 36, "MID", "PER"),
        p("mel", "Adriano Doy", 39, "MID", "PER"), p("mel", "Keith Yáñez", 44, "MID", "PER"), p("mel", "Horacio Orzán", 66, "MID", "ARG"), p("mel", "Abraham Aguinaga", nil, "MID", "PER"),
        p("mel", "Cristian Bordacahar", 7, "FWD", "ARG"), p("mel", "Lautaro Guzmán", 8, "FWD", "ARG"), p("mel", "Bernardo Cuesta", 9, "FWD", "ARG"), p("mel", "Jhonny Vidales", 11, "FWD", "PER"),
        p("mel", "Jefferson Cáceres", 16, "FWD", "PER"), p("mel", "Ryu Yabiku", 40, "FWD", "PER"), p("mel", "Matías Zegarra", 45, "FWD", "PER"), p("mel", "Franco Zanelatto", 77, "FWD", "PER"),
        p("mel", "Jhamir D'Arrigo", 80, "FWD", "PER"), p("mel", "Michel Estela", nil, "FWD", "PER"), p("mel", "Deval Muñoz", nil, "FWD", "PER"),

        // MARK: caj — FC Cajamarca
        p("caj", "Carlos Mosquera", 1, "GK", "COL"), p("caj", "Jonathan Medina", 3, "GK", "PER"), p("caj", "Samuel Aspajo", 12, "GK", "VEN"),
        p("caj", "Pablo Míguez", 6, "DEF", "URU"), p("caj", "Ricardo Lagos Puyén", 13, "DEF", "PER"), p("caj", "Alexis Rodas", 14, "DEF", "PAR"), p("caj", "José Gallardo Flores", 15, "DEF", "PER"),
        p("caj", "Brian Bernaola", 16, "DEF", "PER"), p("caj", "Matías Almirón", 22, "DEF", "URU"), p("caj", "Hairo Timaná", 26, "DEF", "PER"), p("caj", "Jhan Vega", 30, "DEF", "PER"), p("caj", "Carlos Daniel Gómez", 44, "DEF", "PER"),
        p("caj", "Pablo Lavandeira", 10, "MID", "URU"), p("caj", "Mauricio Arrasco", 11, "MID", "PER"), p("caj", "Jefferson Orejuela", 18, "MID", "ECU"), p("caj", "Tomás Andrade", 23, "MID", "ARG"),
        p("caj", "Enmanuel Páucar", 25, "MID", "PER"), p("caj", "Patrick Alegría", 32, "MID", "USA"), p("caj", "Keyvin Paico", 67, "MID", "PER"),
        p("caj", "Sebastien Pineau", 7, "FWD", "CHI"), p("caj", "Hernán Barcos", 9, "FWD", "ARG"), p("caj", "Brandon Palacios", 17, "FWD", "MEX"), p("caj", "Said Peralta", 19, "FWD", "PER"),
        p("caj", "Carlos Meza", 20, "FWD", "PER"), p("caj", "Jonathan Betancourt", 27, "FWD", "ECU"), p("caj", "Fernando Ocas", 29, "FWD", "PER"), p("caj", "Sebastián Enciso", 31, "FWD", "PER"), p("caj", "Arley Rodríguez", 93, "FWD", "COL"),

        // MARK: jpa — Juan Pablo II College (Chongoyape)
        p("jpa", "Ismael Quispe", 12, "GK", "PER"), p("jpa", "Jorge Stucchi", 21, "GK", "PER"), p("jpa", "Matías Alejandro Vega", 23, "GK", "ARG"),
        p("jpa", "Arón Sánchez", 3, "DEF", "PER"), p("jpa", "Paolo Fuentes", 6, "DEF", "PER"), p("jpa", "Bairon Puño", 13, "DEF", "PER"), p("jpa", "Piero Antón", 16, "DEF", "PER"),
        p("jpa", "Martín Peralta", 22, "DEF", "PER"), p("jpa", "Iago Iriarte", 24, "DEF", "ARG"), p("jpa", "Fabio Agurto", 26, "DEF", "PER"), p("jpa", "Josué Canova", 30, "DEF", "PER"),
        p("jpa", "Jair Toledo", 31, "DEF", "PER"), p("jpa", "Sthefano Luzquiños", 33, "DEF", "PER"),
        p("jpa", "Cristian Gabriel García", 5, "MID", "ARG"), p("jpa", "Christian Flores", 8, "MID", "PER"), p("jpa", "Christian Cueva", 10, "MID", "PER"), p("jpa", "Gustavo Aliaga", 11, "MID", "PER"),
        p("jpa", "Nilton Ramírez", 15, "MID", "PER"), p("jpa", "Erinson Ramírez", 18, "MID", "PER"), p("jpa", "Diego Lionel Lozano", 77, "MID", "PER"),
        p("jpa", "Adán Henricks", 7, "FWD", "PAN"), p("jpa", "Jossimar Serrato", 9, "FWD", "PER"), p("jpa", "Adriano Espinoza", 17, "FWD", "PER"), p("jpa", "Jean Piere Valle", 19, "FWD", "PER"),
        p("jpa", "Héctor Bazán", 20, "FWD", "PER"), p("jpa", "Jack Durán", 28, "FWD", "PER"), p("jpa", "Cristhian Tizón", 29, "FWD", "URU"), p("jpa", "Maximiliano Juambeltz", 39, "FWD", "URU"),
        p("jpa", "Martín Alaniz", 50, "FWD", "URU"), p("jpa", "Jorge Alberto Barreto", 80, "FWD", "PER"),

        // MARK: cha — Los Chankas (Andahuaylas)
        p("cha", "Hairo Camacho", 1, "GK", "PER"), p("cha", "Luis Pretel", 12, "GK", "PER"), p("cha", "Franco Saravia", 32, "GK", "PER"),
        p("cha", "Héctor González", 2, "DEF", "ARG"), p("cha", "Brayan Guevara", 14, "DEF", "PER"), p("cha", "Gonzalo Rizzo", 24, "DEF", "URU"), p("cha", "David Gonzáles", 26, "DEF", "PER"),
        p("cha", "Michael Kaufman", 30, "DEF", "PER"), p("cha", "Ayrthon Quintana", 31, "DEF", "PER"), p("cha", "Carlos Pimienta", 33, "DEF", "URU"), p("cha", "José Cárdenas", 37, "DEF", "PER"),
        p("cha", "Jorge Palomino", 5, "MID", "PER"), p("cha", "Abdiel Ayarza", 6, "MID", "PAN"), p("cha", "Juan Ospina", 7, "MID", "COL"), p("cha", "Adrián Quiroz", 8, "MID", "PER"),
        p("cha", "Franco Nicolás Torres", 10, "MID", "ARG"), p("cha", "Christian Velarde", 17, "MID", "PER"), p("cha", "Sebastián Zarabia", 38, "MID", "PER"), p("cha", "Félix Espinoza", 77, "MID", "PER"),
        p("cha", "Jarlín Quintero", 11, "FWD", "COL"), p("cha", "Kelvin Sánchez", 15, "FWD", "PER"), p("cha", "Oshiro Takeuchi", 18, "FWD", "PER"), p("cha", "Marlon Torres", 20, "FWD", "PER"),
        p("cha", "Kenyi Barrios", 27, "FWD", "PER"), p("cha", "Janio Pósito", 89, "FWD", "PER"),

        // MARK: sba — Sport Boys (Callao)
        p("sba", "Jeferson Nolasco", 1, "GK", "PER"), p("sba", "Sebastián Oblitas", 12, "GK", "PER"), p("sba", "Diego Melián", 22, "GK", "URU"),
        p("sba", "Luciano Zambrano", 2, "DEF", "PER"), p("sba", "Carlos Augusto Zambrano", 3, "DEF", "PER"), p("sba", "Renzo Alfani", 4, "DEF", "ARG"), p("sba", "Mathías Llontop", 13, "DEF", "PER"),
        p("sba", "Evanz Cruz", 15, "DEF", "PER"), p("sba", "Emilio Saba", 17, "DEF", "PSE"), p("sba", "Nicolás Valencia Saldarriaga", 18, "DEF", "PER"), p("sba", "Diego Contreras", 25, "DEF", "PER"),
        p("sba", "Hansell Riojas", 26, "DEF", "PER"), p("sba", "Nilson Loyola", 29, "DEF", "PER"), p("sba", "Gustavo Dulanto", 55, "DEF", "PER"),
        p("sba", "Federico Illanes", 5, "MID", "ARG"), p("sba", "Augusto Leonel Solís", 6, "MID", "PER"), p("sba", "Nicolás Da Campo", 8, "MID", "ARG"), p("sba", "Jostin Alarcón", 10, "MID", "PER"),
        p("sba", "Erick Gonzales", 28, "MID", "PER"), p("sba", "Nicolás Jefferson Paz", 36, "MID", "PER"), p("sba", "Miguel Trauco", 47, "MID", "PER"), p("sba", "Yuriel Celi", 77, "MID", "PER"), p("sba", "Christian Cueva", 99, "MID", "PER"),
        p("sba", "Luis Urruti", 11, "FWD", "URU"), p("sba", "Rolando Díaz Cáceres", 14, "FWD", "PER"), p("sba", "Adrián Valiente", 16, "FWD", "PER"), p("sba", "Alexis Huamán", 21, "FWD", "PER"),
        p("sba", "Percy Liza", 30, "FWD", "PER"), p("sba", "Rodrigo Torres", 31, "FWD", "PER"), p("sba", "Pablo Erustes", 32, "FWD", "ARG"), p("sba", "José María Davey", 33, "FWD", "PER"), p("sba", "Adrián Santana", 37, "FWD", "PER"),

        // MARK: hua — Sport Huancayo
        p("hua", "Massimo Sandi", 1, "GK", "PER"), p("hua", "Ángel Zamudio", 12, "GK", "PER"), p("hua", "Diego Campos", 21, "GK", "PER"), p("hua", "Edú Ccorahua", 29, "GK", "PER"),
        p("hua", "Hugo Ángeles", 2, "DEF", "PER"), p("hua", "Gustavo Rissi", 3, "DEF", "BRA"), p("hua", "Juan Barreda", 4, "DEF", "PER"), p("hua", "Axel Chávez", 15, "DEF", "PER"),
        p("hua", "Jean Franco Falconí", 16, "DEF", "PER"), p("hua", "Marcelo Gaona", 26, "DEF", "PER"), p("hua", "Jeremy Rostaing", 28, "DEF", "PER"), p("hua", "Jimmy Valoyes", 70, "DEF", "COL"), p("hua", "Yonatan Murillo", 92, "DEF", "COL"),
        p("hua", "Leonardo Villar", 6, "MID", "PER"), p("hua", "Diego Carabaño", 8, "MID", "PER"), p("hua", "Javier Sanguinetti", 11, "MID", "ARG"), p("hua", "Ricardo Salcedo", 22, "MID", "PER"), p("hua", "Edu Villar", 38, "MID", "PER"),
        p("hua", "Rick Campodónico", 7, "FWD", "PER"), p("hua", "Juan Martínez", 9, "FWD", "PER"), p("hua", "Nahuel Luján", 10, "FWD", "ARG"), p("hua", "Yorleys Mena", 17, "FWD", "COL"),
        p("hua", "Ronal Huaccha", 19, "FWD", "PER"), p("hua", "Jeremy Canela", 20, "FWD", "PER"), p("hua", "Piero Magallanes", 23, "FWD", "PER"), p("hua", "Franco Caballero", 99, "FWD", "ARG"),

        // MARK: cri — Sporting Cristal
        p("cri", "Diego Enríquez", 1, "GK", "PER"), p("cri", "Renato Solís", 12, "GK", "PER"), p("cri", "César Bautista", 33, "GK", "PER"), p("cri", "Tomás Dulanto", 35, "GK", "PER"),
        p("cri", "Duham Ballumbrosio", 2, "DEF", "PER"), p("cri", "Anderson Villacorta", 4, "DEF", "PER"), p("cri", "Rafael Lutiger", 5, "DEF", "PER"), p("cri", "Leandro Sosa", 8, "DEF", "PER"),
        p("cri", "Carlos Salgado", 17, "DEF", "PER"), p("cri", "Juan Cruz González", 18, "DEF", "ARG"), p("cri", "Miguel Araujo", 20, "DEF", "PER"), p("cri", "Leonardo Díaz", 32, "DEF", "PER"),
        p("cri", "Fabrizio Lora", 37, "DEF", "PER"), p("cri", "Joao Cuenca", 41, "DEF", "PER"), p("cri", "Cristiano da Silva", 90, "DEF", "BRA"), p("cri", "Luis Abram", 96, "DEF", "PER"),
        p("cri", "Agustín Álvarez", 6, "MID", "URU"), p("cri", "Christofer Gonzales", 10, "MID", "PER"), p("cri", "Cristian Benavente", 14, "MID", "PER"), p("cri", "Yoshimar Yotún", 19, "MID", "PER"),
        p("cri", "Catriel Cabellos", 21, "MID", "PER"), p("cri", "Martín Távara", 25, "MID", "PER"), p("cri", "Ian Wisdom", 26, "MID", "PER"), p("cri", "Gabriel Santana", 27, "MID", "BRA"),
        p("cri", "Yamir del Valle", 34, "MID", "PER"), p("cri", "Lionel Herrera", 43, "MID", "PER"), p("cri", "Gerson Castillo", 44, "MID", "PER"),
        p("cri", "Santiago González", 7, "FWD", "ARG"), p("cri", "Irven Ávila", 11, "FWD", "PER"), p("cri", "Luis Iberico", 16, "FWD", "PER"), p("cri", "Michael Hoyos", 22, "FWD", "ARG"),
        p("cri", "Maxloren Castro", 23, "FWD", "PER"), p("cri", "Hernán Barcos", 29, "FWD", "ARG"), p("cri", "Jair Moretti", 40, "FWD", "PER"), p("cri", "Juan Manuel Cuesta", 77, "FWD", "COL"),

        // MARK: uni — Universitario de Deportes
        p("uni", "Diego Romero Cachay", 1, "GK", "PER"), p("uni", "Jhefferson Rodríguez", 12, "GK", "PER"), p("uni", "Miguel Ángel Vargas", 25, "GK", "CHI"),
        p("uni", "Caín Fara", 2, "DEF", "ARG"), p("uni", "Williams Riveros", 3, "DEF", "PAR"), p("uni", "Ánderson Santamaría", 4, "DEF", "PER"), p("uni", "Matías Di Benedetto", 5, "DEF", "ARG"),
        p("uni", "Hugo Ancajima", 26, "DEF", "PER"), p("uni", "Aldo Corzo", 29, "DEF", "PER"), p("uni", "César Inga", 33, "DEF", "PER"),
        p("uni", "Jesús Castillo Molina", 6, "MID", "PER"), p("uni", "Héctor Fértoli", 8, "MID", "ARG"), p("uni", "Horacio Calcaterra", 10, "MID", "PER"), p("uni", "Juan Requena", 15, "MID", "ARG"),
        p("uni", "Jairo Concha", 17, "MID", "PER"), p("uni", "Jordan Guivin", 21, "MID", "PER"), p("uni", "Jorge Murrugarra", 23, "MID", "PER"), p("uni", "Adrian Quiroz", 28, "MID", "PER"),
        p("uni", "Fabián Cabanillas", 36, "MID", "PER"), p("uni", "Sebastián Flores Mallqui", 40, "MID", "PER"), p("uni", "Piero Quispe", 39, "MID", "PER"),
        p("uni", "José Rivera Martínez", 11, "FWD", "PER"), p("uni", "Gianluca Lapadula", 18, "FWD", "PER"), p("uni", "Edison Flores", 19, "FWD", "PER"), p("uni", "Álex Valera", 20, "FWD", "PER"),
        p("uni", "Andy Polo", 24, "FWD", "PER"), p("uni", "Lisandro Alzugaray", 30, "FWD", "ARG"), p("uni", "Jhon Jairo Guzmán", 37, "FWD", "PER"), p("uni", "Bryan Reyna", 77, "FWD", "PER"),

        // MARK: utc — UTC Cajamarca
        p("utc", "Ángelo Campos", 1, "GK", "PER"), p("utc", "Ricardo Bettochi", 21, "GK", "PER"), p("utc", "Ignacio Barrios", 29, "GK", "URU"),
        p("utc", "Bruno Duarte", 2, "DEF", "ARG"), p("utc", "Manuel Ganoza", 3, "DEF", "PER"), p("utc", "Junior Huerto", 5, "DEF", "PER"), p("utc", "Francesco Cavagna", 6, "DEF", "PER"),
        p("utc", "Dylan Caro", 13, "DEF", "PER"), p("utc", "Luis Garro", 17, "DEF", "PER"), p("utc", "Piero Serra", 27, "DEF", "PER"), p("utc", "Kevin Osías Ramírez", 28, "DEF", "PER"), p("utc", "Gilmar Paredes", 35, "DEF", "PER"),
        p("utc", "David Dioses", 8, "MID", "PER"), p("utc", "Marcos Lliuya", 10, "MID", "PER"), p("utc", "Joshua Cantt", 15, "MID", "PER"), p("utc", "Arquímedes Figuera", 16, "MID", "VEN"), p("utc", "Luis Arce Mina", 88, "MID", "ECU"),
        p("utc", "Jhosep Núñez", 7, "FWD", "PER"), p("utc", "Marlon de Jesús", 9, "FWD", "ECU"), p("utc", "Abdiel Arroyo", 11, "FWD", "PAN"), p("utc", "Michel Rasmussen", 14, "FWD", "PER"),
        p("utc", "Santiago Gálvez", 18, "FWD", "PER"), p("utc", "Adolfo Muñoz", 19, "FWD", "ECU"), p("utc", "David Camacho", 22, "FWD", "COL"),
    ]
}
