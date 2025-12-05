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
        seats = []
    }
    
   /* func toggleSeatStatus(_ seat: Seat, userId:String){
        let newStatus: SeatStatus
        
        switch seat.status {
        case .available:
            newStatus = .sold
        case .sold:
            newStatus = .available
        case .reserved:
            newStatus = .available
        }
        
        isLoading = true
        
        eventService.updateTempSeatStatus(seat, newStatus: newStatus){ [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result{
                case.success: break
                case .failure(let error): self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        /*eventService.updateSeatStatus(seat, newStatus: newStatus, userId: userId){ [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result{
                case .success:
                    print("Estado de asiento actualizado")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }*/
    }*/
    
    func seatsInSection(_ section: Int) -> [Seat] {
        let filteredSeats = seats.filter { $0.section == section }
        print("Sección \(section) tiene \(filteredSeats.count) asientos")
        return filteredSeats
    }
        
    func seatsInSectionAndRow(section: Int, row: Int) -> [Seat] {
        return seats.filter { $0.section == section && $0.row == row }
    }
    
}
