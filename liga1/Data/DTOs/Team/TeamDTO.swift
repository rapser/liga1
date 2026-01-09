//
 //  TeamDTO.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object para Team desde Firestore
struct TeamDTO: Codable {
    @DocumentID var id: String?
    let name: String?
    let city: String?
    let stadium: String?
    let matchesPlayed: Int?
    let matchesWon: Int?
    let matchesDrawn: Int?
    let matchesLost: Int?
    let goalsScored: Int?
    let goalsAgainst: Int?
    let goalDifference: Int?
    let points: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case city
        case stadium
        case matchesPlayed
        case matchesWon
        case matchesDrawn
        case matchesLost
        case goalsScored
        case goalsAgainst
        case goalDifference
        case points
    }

    init(id: String? = nil, name: String?, city: String?, stadium: String?, matchesPlayed: Int?, matchesWon: Int?, matchesDrawn: Int?, matchesLost: Int?, goalsScored: Int?, goalsAgainst: Int?, goalDifference: Int?, points: Int?) {
        self.id = id
        self.name = name
        self.city = city
        self.stadium = stadium
        self.matchesPlayed = matchesPlayed
        self.matchesWon = matchesWon
        self.matchesDrawn = matchesDrawn
        self.matchesLost = matchesLost
        self.goalsScored = goalsScored
        self.goalsAgainst = goalsAgainst
        self.goalDifference = goalDifference
        self.points = points
    }
}
