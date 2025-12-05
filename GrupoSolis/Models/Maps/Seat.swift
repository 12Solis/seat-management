//
//  Seat.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore

struct Seat: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    
    let seatMapId: String
    let section: Int
    let row: Int
    let number: Int
    var status: SeatStatus
    var tempStatus: SeatStatus
    var lastUpdate: Date?
    var lastUpdatedBy: String?
    var price: Double?
    var priceCategory: String?
    
    init(id: String? = nil, seatMapId: String, section: Int, row: Int, number: Int, status: SeatStatus,tempStatus:SeatStatus, lastUpdatedBy: String?,price: Double? = nil, priceCategory: String? = nil) {
        self.id = id
        self.seatMapId = seatMapId
        self.section = section
        self.row = row
        self.number = number
        self.status = status
        self.tempStatus = tempStatus
        self.lastUpdate = Date()
        self.lastUpdatedBy = lastUpdatedBy
        self.price = price
        self.priceCategory = priceCategory
    }
}

enum SeatStatus: String, Codable {
    case available = "available"
    case sold = "sold"
    case reserved = "reserved"
}
