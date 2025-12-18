//
//  SeatMapViewModel.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class SeatMapViewModel: ObservableObject {
    
    @Published var seats: [Seat] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var selectedSeat: Seat?
    
    private var listenerRegistration: ListenerRegistration?
    private let eventService = EventService()
    private let cancellables = Set<AnyCancellable>()
    
    deinit {
        stopListening()
    }
    
    func loadSeatsForMap(seatMapId:String){
        isLoading = true
        
        self.listenerRegistration?.remove()
        self.listenerRegistration = eventService.listenToSeats(seatMapId: seatMapId) { [weak self] newSeats in
            DispatchQueue.main.async {
                self?.seats = newSeats
                self?.isLoading = false
                print("Asientos cargados: \(newSeats.count)")
            }
        }

    }
    func stopListening(){
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    
    func seatsInSection(_ section: Int) -> [Seat] {
        let filteredSeats = seats.filter { $0.section == section }
        print("Sección \(section) tiene \(filteredSeats.count) asientos")
        return filteredSeats
    }
        
    func seatsInSectionAndRow(section: Int, row: Int) -> [Seat] {
        return seats.filter { $0.section == section && $0.row == row }
    }
    
    var soldSeatsCount: Int {
        return seats.filter { $0.status == .sold }.count
    }
    var reservedSeatsCount: Int {
        return seats.filter { $0.status == .reserved }.count
    }
    
    var totalRevenue: Int {
        let total = seats.reduce(0.0) { partialResult, seat in
            if seat.status == .available {
                return partialResult
            }
            
            if seat.status == .reserved {
                return partialResult + (seat.amountPaid ?? 0.0)
            } else if seat.status == .sold {
                return partialResult + (seat.price ?? 0.0)
            }
            
            return partialResult
        }
        return Int(total)
    }
    
    var totalCash: Int {
        let seatsPaidInCash = seats.filter {
            ($0.status == .sold || $0.status == .reserved) && $0.paymentMethod == .cash
        }
        
        let seatsLiquidatedInCash = seats.filter {
            ($0.status == .sold) && $0.liquidatePaymentMethod == .cash
        }
        
        let sumPaid = seatsPaidInCash.reduce(0.0) { $0 + ($1.amountPaid ?? 0.0) }
        
        let sumLiquidated = seatsLiquidatedInCash.reduce(0.0) { partialResult, seat in
            let price = seat.price ?? 0.0
            let paid = seat.amountPaid ?? 0.0
            return partialResult + (price - paid)
        }
        
        return Int(sumPaid + sumLiquidated)
    }

}
