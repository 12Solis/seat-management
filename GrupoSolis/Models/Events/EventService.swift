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
    

    func deleteEvent(eventId: String, completion: @escaping(Result<Void,Error>) -> Void) {
        
        db.collection("seatsMaps")
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments { [weak self] mapSnapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let self = self else { return }
                

                let batch = self.db.batch()
                
                let eventRef = self.db.collection("events").document(eventId)
                batch.deleteDocument(eventRef)
                
                guard let mapDocuments = mapSnapshot?.documents, !mapDocuments.isEmpty else {
                    self.commitBatch(batch, completion: completion)
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                for mapDoc in mapDocuments {
                    batch.deleteDocument(mapDoc.reference)
                    
                    let seatMapId = mapDoc.documentID
                    
                    dispatchGroup.enter()
                    self.db.collection("seats")
                        .whereField("seatMapId", isEqualTo: seatMapId)
                        .getDocuments { seatSnapshot, seatError in
                            if let seatDocs = seatSnapshot?.documents {
                                for seatDoc in seatDocs {
                                    batch.deleteDocument(seatDoc.reference)
                                }
                            }
                            dispatchGroup.leave()
                        }
                }
                
                dispatchGroup.notify(queue: .global()) {
                    self.commitBatch(batch, completion: completion)
                }
            }
    }

    private func commitBatch(_ batch: WriteBatch, completion: @escaping(Result<Void,Error>) -> Void) {
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Eliminación completada (Evento + Mapa + Asientos)")
                completion(.success(()))
            }
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

    func updateSelectedSeats(seats: [Seat], userId: String,newStatus:SeatStatus ,buyer:String, amountPaid:Double,completion: @escaping(Result<Void, Error>) -> Void) {
        let batch = db.batch()
        
        for seat in seats {
            guard let seatId = seat.id else { continue }
            let ref = db.collection("seats").document(seatId)
            
            let updatedSeat = Seat(
                id: seatId,
                seatMapId: seat.seatMapId,
                section: seat.section,
                row: seat.row,
                number: seat.number,
                status: newStatus,
                lastUpdatedBy: userId,
                price: seat.price,
                priceCategory: seat.priceCategory,
                buyerName: buyer,
                amountPaid: amountPaid
            )
            
            do {
                try batch.setData(from: updatedSeat, forDocument: ref)
            } catch {
                print("Error codificando asiento para batch: \(error)")
            }
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func initializeSeatsFromMap(seatMap: SeatsMap,prices:[Int : [Int : Double]]?, completion: @escaping(Result<Void,Error>)->Void){
        
        guard let seatMapId = seatMap.id else {
            completion(.failure(NSError(domain: "Sin ID", code: 0)))
            return
        }

        let batch = db.batch()

        for (sectionIndex, section) in seatMap.layoutData.sections.enumerated() {
                
                let sectionPrices = prices?[sectionIndex]
                let sectionLetter = ["A", "B", "C", "D", "E"][sectionIndex] ?? "\(sectionIndex)"
                for row in section.rows {
                    let rowNumber = Int(row.name) ?? 0
                    let rowPrice = sectionPrices?[rowNumber]
                    let categoryName = rowPrice != nil ? "Sección \(sectionLetter) - Fila \(rowNumber)" : nil
                    
                    
                    for seatNumber in 1...row.seatsCount {
                        
                        let customDocID = "\(sectionIndex)-\(rowNumber)-\(seatNumber)"
                        let uniqueDocId = "\(seatMapId)_\(customDocID)"
                        let ref = db.collection("seats").document(uniqueDocId)
                        
                        let seat = Seat(
                            id: uniqueDocId,
                            seatMapId: seatMapId,
                            section: sectionIndex,
                            row: rowNumber,
                            number: seatNumber,
                            status: .available,
                            lastUpdatedBy: nil,
                            price: rowPrice,
                            priceCategory: categoryName
                        )
                        
                        try? batch.setData(from: seat, forDocument: ref)
                    }
                }
            }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Se crearon los asientos exitosamente")
                completion(.success(()))
            }
        }
    }
    
}

