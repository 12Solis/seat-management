//
//  TemplateService.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

class TemplateService: ObservableObject {
    private let db = Firestore.firestore()
    private let eventService = EventService()
    
    func fetchTemplates(completion: @escaping (Result<[SeatMapTemplate], Error>) -> Void) {
        print("Intentando cargar plantillas desde Firebase...")
        
        db.collection("seatMapTemplates")
            .order(by: "name")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error en consulta Firebase: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                
                var templates: [SeatMapTemplate] = []
                
                for document in snapshot?.documents ?? [] {
                    print("Procesando documento: \(document.documentID)")
                    let data = document.data()
                    
                   
                    print("Campos del documento: \(data.keys.sorted())")
                    
                    do {
                        print("Intentando decodificar template...")
                        let template = try document.data(as: SeatMapTemplate.self)
                        templates.append(template)
                        print("Template decodificado exitosamente: \(template.name)")
                        print("StageData: \(template.stageData != nil ? "PRESENTE" : "AUSENTE")")
                        print("Secciones: \(template.layoutData.sections.count)")
                        
                    } catch {
                        print("ERROR en decodificación: \(error)")
                        print("Error localizado: \(error.localizedDescription)")
                        
                        
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Key no encontrada: \(key), contexto: \(context)")
                            case .typeMismatch(let type, let context):
                                print("Type mismatch: \(type), contexto: \(context)")
                            case .valueNotFound(let type, let context):
                                print("Value no encontrado: \(type), contexto: \(context)")
                            case .dataCorrupted(let context):
                                print("Data corrupta: \(context)")
                            @unknown default:
                                print("Error desconocido")
                            }
                        }
                    }
                }
                
                print("Templates finales: \(templates.count)")
                completion(.success(templates))
            }
    }
    
    func createSeatMapFromTemplate(template: SeatMapTemplate, eventId: String, prices: [Int : [Int : Double]]?, completion: @escaping (Result<String, Error>) -> Void) {
        var seatMap = SeatsMap(
            eventId: eventId,
            name: template.name,
            layoutData: template.layoutData
        )
        
        eventService.createSeatMap(seatMap) { result in
            switch result {
            case .success(let seatMapId):
                seatMap.id = seatMapId
                
                self.eventService.initializeSeatsFromMap(seatMap: seatMap, prices: prices) { seatResult in
                    switch seatResult {
                    case .success:
                        completion(.success(seatMapId))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
