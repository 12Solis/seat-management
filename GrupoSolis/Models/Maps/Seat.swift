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
    var lastUpdate: Date?
    var lastUpdatedBy: String?
    var price: Double?
    var priceCategory: String?
    var buyerName: String?
    var amountPaid: Double?
    var paymentMethod: PaymentMethods?
    
    init(id: String? = nil, seatMapId: String, section: Int, row: Int, number: Int, status: SeatStatus, lastUpdatedBy: String?,price: Double? = nil, priceCategory: String? = nil, buyerName: String? = nil, amountPaid: Double? = nil, paymentMethod: PaymentMethods? = nil) {
        self.id = id
        self.seatMapId = seatMapId
        self.section = section
        self.row = row
        self.number = number
        self.status = status
        self.lastUpdate = Date()
        self.lastUpdatedBy = lastUpdatedBy
        self.price = price
        self.priceCategory = priceCategory
        self.buyerName = buyerName
        self.amountPaid = amountPaid
        self.paymentMethod = paymentMethod
    }
}

enum SeatStatus: String, Codable {
    case available = "available"
    case sold = "sold"
    case reserved = "reserved"
}
enum PaymentMethods: String, CaseIterable, Identifiable, Codable {
    case cash = "Efectivo"
    case bankWire = "Transferencia"
    var id: String { self.rawValue }
}
