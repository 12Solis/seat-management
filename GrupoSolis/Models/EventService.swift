//
//  EventService.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

class EventService: ObservableObject {
    private let db = Firestore.firestore()
    
    //MARK: operaciones de evento
    
    func createEvent(_ event: Event, completion: @escaping(Result<String,Error>)->Void){
        do{
            let ref = try db.collection("events").addDocument(from: event)
            completion(.success(ref.documentID))
        }catch{
            completion(.failure(error))
        }
    }
    
    func fetchEvents(completion: @escaping(Result<[Event],Error>)->Void){
        db.collection("events")
            .order(by: "date",descending: false)
            .getDocuments{snapshot,error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                let events = snapshot?.documents.compactMap{document in
                    try? document.data(as: Event.self)
                } ?? []
                completion(.success(events))
            }
    }
    
    func deleteEvent(eventId: String, completion: @escaping(Result<Void,Error>) ->Void){
        db.collection("events").document(eventId).delete(){error in
            if let error = error{
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    //MARK: operaciones de mapa de asientos
    
    func createSeatMap(_ seatMap: SeatsMap, completion: @escaping(Result<String,Error>)->Void){
        do{
            let ref = try db.collection("seatsMaps").addDocument(from: seatMap)
            completion(.success(ref.documentID))
        }catch{
            completion(.failure(error))
        }
    }
    
    func fetchSeatMaps(forEventId eventId: String ,completion: @escaping(Result<[SeatsMap],Error>)->Void){
        db.collection("seatsMaps")
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments{snapshot, error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                
                let seatsMaps = snapshot?.documents.compactMap{document in
                    try? document.data(as: SeatsMap.self)
                } ?? []
                
                completion(.success(seatsMaps))
                
            }
    }
    
    //MARK: opearciones de asiento
    
    func listenToSeats(seatMapId:String , completion: @escaping ([Seat]) -> Void){
        db.collection("seats")
            .whereField("seatMapId", isEqualTo: seatMapId)
            .addSnapshotListener{snapshot,error in
                if let error = error{
                    print("Error al escuchar cambio de asientos: \(error)")
                    return
                }
                
                let seats = snapshot?.documents.compactMap{document in
                    try? document.data(as: Seat.self)
                } ?? []
                
                completion(seats)
            }
    }
    
    func updateSeatStatus(_ seat: Seat, newStatus: SeatStatus, userId: String, completion: @escaping(Result<Void,Error>)->Void){
        var updatedSeat = seat
        updatedSeat = Seat(
            seatMapId: seat.seatMapId,
            section: seat.section,
            row: seat.row,
            number: seat.number,
            status: newStatus,
            lastUpdatedBy: userId
        )
        
        do{
            try db.collection("seats").document(seat.id).setData(from: updatedSeat)
            completion(.success(()))
        } catch{
            completion(.failure(error))
        }
    }
    
    func initializeSeatsFromMap(seatMap: SeatsMap, completion: @escaping(Result<Void,Error>)->Void){
        
        guard let seatMapId = seatMap.id else {
            completion(.failure(NSError(domain: "SeatsMap sin ID", code: 0)))
            return
        }
        var seats: [Seat] = []
        
        for(sectionIndex,section) in seatMap.layoutData.sections.enumerated(){
            for(rowIndex,row) in section.rows.enumerated(){
                print("🔧 Procesando sección \(sectionIndex), fila \(rowIndex), asientos: \(row.seatsCount)")
                for seatNumber in 1...row.seatsCount{
                    let seat = Seat(
                        seatMapId: seatMapId,
                        section: sectionIndex,
                        row: Int(row.name) ?? 0,
                        number: seatNumber,
                        status: .available,
                        lastUpdatedBy: ""
                    )
                    seats.append(seat)
                    print("🔧 Creado asiento: \(seat.id)")
                }
            }
            /*for row in section.rows{
                for seatNumber in 1...row.seatsCount{
                    let seat = Seat(
                        seatMapId: seatMapId,
                        section: sectionIndex,
                        row: Int(row.name) ?? 0,
                        number: seatNumber,
                        status: .available,
                        lastUpdatedBy: ""
                    )
                    seats.append(seat)
                }
            }*/
        }
        print("🔧 Total de asientos a crear: \(seats.count)")
        
        let batch = db.batch()
        for seat in seats{
            let ref = db.collection("seats").document(seat.id)
            do{
                try batch.setData(from: seat, forDocument: ref)
            } catch {
                completion(.failure(error))
                return
            }
            
        }
        
        batch.commit{ error in
            if let error = error{
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
}

