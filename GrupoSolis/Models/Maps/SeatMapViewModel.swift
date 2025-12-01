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
        /*eventService.listenToSeats(seatMapId: seatMapId){ [weak self] seats in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.seats = seats
                print("\(seats.count) asientos cargados para seatMapId: \(seatMapId)")
                //Debug
                if seats.isEmpty {
                    print("No se encontraron asientos. Posibles causas:")
                    print("   - El seatMapId no existe en Firebase")
                    print("   - Los asientos no tienen el seatMapId correcto")
                    print("   - Problema con la consulta de Firestore")
                } else {
                    print("🔍 Primeros 3 asientos cargados:")
                    for seat in seats.prefix(3) {
                        print("   - \(seat.id) -> seatMapId: \(seat.seatMapId)")
                    }
                }
                
            }
        }*/
    }
    func stopListening(){
        listenerRegistration?.remove()
        listenerRegistration = nil
        seats = []
    }
    
    func toggleSeatStatus(_ seat: Seat, userId:String){
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
        
        eventService.updateSeatStatus(seat, newStatus: newStatus, userId: userId){ [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result{
                case .success:
                    print("Estado de asiento actualizado")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func seatsInSection(_ section: Int) -> [Seat] {
        let filteredSeats = seats.filter { $0.section == section }
        print("Sección \(section) tiene \(filteredSeats.count) asientos")
        return filteredSeats
    }
        
    func seatsInSectionAndRow(section: Int, row: Int) -> [Seat] {
        return seats.filter { $0.section == section && $0.row == row }
    }
    
    func createTestSeatMapAndSeats(eventId: String, completion: @escaping(Result<String,Error>)->Void){
        isLoading = true
        let layoutData = LayoutData(
            sections: [
                SeatSection(
                    name: "Platea",
                    rows: [
                        SeatRow(name: "1", seatsCount: 10, startPosX: 0, startPosY: 0),
                        SeatRow(name: "2", seatsCount: 10, startPosX: 0, startPosY: 30),
                        SeatRow(name: "3", seatsCount: 8, startPosX: 20, startPosY: 60)
                    ]
                ),
                SeatSection(
                    name: "Balcón",
                    rows: [
                        SeatRow(name: "1", seatsCount: 6, startPosX: 0, startPosY: 120),
                        SeatRow(name: "2", seatsCount: 6, startPosX: 0, startPosY: 150)
                    ]
                )
            ]
        )
        
        let testSeatsMap = SeatsMap(eventId: eventId, name: "Mapa de prueba", layoutData: layoutData)
        
        eventService.createSeatMap(testSeatsMap){[weak self] result in
            switch result{
                case .success(let seatMapId):
                    print("Seat map creado con exito, id:\(seatMapId)")
                    var testSeatsMapWithId = testSeatsMap
                    testSeatsMapWithId.id = seatMapId
                
                    self?.eventService.initializeSeatsFromMap(seatMap: testSeatsMapWithId) { seatResult in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            switch seatResult {
                            case .success:
                                print("Asientos de prueba creados exitosamente")
                                completion(.success(seatMapId))
                            case .failure(let error):
                                print("Error creando asientos: \(error)")
                                completion(.failure(error))
                            }
                        }
                    }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    print("Error creando mapa de asientos: \(error)")
                    completion(.failure(error))
                }
                
            }
        }
        
        
        
    }
    
}
