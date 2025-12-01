//
//  Seat.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore

struct Seat: Codable, Identifiable {
    @DocumentID var id: String?
    
    let seatMapId: String
    let section: Int
    let row: Int
    let number: Int
    var status: SeatStatus
    var lastUpdate: Date?
    var lastUpdatedBy: String?
    
    init(id: String? = nil, seatMapId: String, section: Int, row: Int, number: Int, status: SeatStatus, lastUpdatedBy: String?) {
        self.id = id
        self.seatMapId = seatMapId
        self.section = section
        self.row = row
        self.number = number
        self.status = status
        self.lastUpdate = Date()
        self.lastUpdatedBy = lastUpdatedBy
    }
}

enum SeatStatus: String, Codable {
    case available = "available"
    case sold = "sold"
    case reserved = "reserved"
}
