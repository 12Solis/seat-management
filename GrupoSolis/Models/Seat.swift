//
//  Seat.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore

struct Seat: Codable, Identifiable {
    var id : String {"\(section)-\(row)-\(number)"}
    
    let seatMapId: String
    let section: Int
    let row: Int
    let number: Int
    let status: SeatStatus
    let lastUpdate: Date?
    let lastUpdatedBy: String?
    
    init(seatMapId: String, section: Int, row: Int, number: Int, status: SeatStatus, lastUpdatedBy: String?) {
        self.seatMapId = seatMapId
        self.section = section
        self.row = row
        self.number = number
        self.status = status
        self.lastUpdate = Date()
        self.lastUpdatedBy = lastUpdatedBy
    }
}

enum SeatStatus: String,Codable {
    case available = "available"
    case sold = "sold"
    case reserved = "reserved"
}
