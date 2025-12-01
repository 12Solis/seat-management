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
    
    func listenToSeats(seatMapId:String , completion: @escaping ([Seat]) -> Void) -> ListenerRegistration? {
        return db.collection("seats")
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
    func updateSeatStatus(_ seat: Seat, newStatus: SeatStatus, userId: String, completion: @escaping(Result<Void,Error>)->Void) {

        guard let seatDocId = seat.id else {
            completion(.failure(NSError(domain: "Error de ID", code: -1, userInfo: [NSLocalizedDescriptionKey: "El asiento no tiene ID de documento"])))
            return
        }

        let updatedSeat = Seat(
            id: seatDocId,
            seatMapId: seat.seatMapId,
            section: seat.section,
            row: seat.row,
            number: seat.number,
            status: newStatus,
            lastUpdatedBy: userId
        )
        
        do {
            try db.collection("seats").document(seatDocId).setData(from: updatedSeat)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    func initializeSeatsFromMap(seatMap: SeatsMap, completion: @escaping(Result<Void,Error>)->Void){
        
        guard let seatMapId = seatMap.id else {
            completion(.failure(NSError(domain: "Sin ID", code: 0)))
            return
        }

        let batch = db.batch()
        var count = 0

        for (sectionIndex, section) in seatMap.layoutData.sections.enumerated() {
            for row in section.rows {
                let rowNumber = Int(row.name) ?? 0
                
                for seatNumber in 1...row.seatsCount {

                    let customDocID = "\(sectionIndex)-\(rowNumber)-\(seatNumber)"
                    let seat = Seat(
                        seatMapId: seatMapId,
                        section: sectionIndex,
                        row: rowNumber,
                        number: seatNumber,
                        status: .available,
                        lastUpdatedBy: nil
                    )
                    let uniqueDocId = "\(seatMapId)_\(customDocID)"
                    
                    let ref = db.collection("seats").document(uniqueDocId)
                    
                    do {
                        try batch.setData(from: seat, forDocument: ref)
                        count += 1
                    } catch {
                        print("Error codificando asiento: \(error)")
                    }
                }
            }
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Se crearon \(count) asientos exitosamente")
                completion(.success(()))
            }
        }
    }
    
}

