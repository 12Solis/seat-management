//
//  TemplateService.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

/*import Foundation
import FirebaseFirestore
import Combine

class TemplateService: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchTemplates(completion: @escaping (Result<[SeatMapTemplate],Error>) -> Void) {
        print("🔄 Intentando cargar plantillas desde Firebase...")
        
        db.collection("seatMapTemplates")
            .order(by: "name")
            .getDocuments { snapshot,error in
                if let error = error{
                    print("❌ Error en consulta Firebase: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                print("📊 Snapshots recibidos: \(snapshot?.documents.count ?? 0) documentos")
                
                snapshot?.documents.forEach { document in
                    print("📄 Documento ID: \(document.documentID)")
                    print("📄 Datos: \(document.data())")
                }
                
                let templates = snapshot?.documents.compactMap{document in
                    do {
                        let template = try document.data(as: SeatMapTemplate.self)
                        print("✅ Template decodificado: \(template.name)")
                        return template
                    } catch {
                        print("❌ Error decodificando template \(document.documentID): \(error)")
                        return nil
                    }
                } ?? []
                
                print("✅ Templates finales: \(templates.count)")
                completion(.success(templates as! [SeatMapTemplate]))
            }
    }
    
    func createSeatMapFromTemplate(template: SeatMapTemplate, eventId:String, completion:@escaping(Result<String,Error>) -> Void){
        let seatMap = SeatsMap(
            eventId: eventId, name: template.name, layoutData: template.layoutData
        )
        let eventService = EventService()
        eventService.createSeatMap(seatMap){result in
            switch result{
            case .success(let seatMapId):
                var seatMapWithId = seatMap
                seatMapWithId.id = seatMapId
                eventService.initializeSeatsFromMap(seatMap: seatMapWithId){seatResult in
                    switch seatResult{
                    case .success:
                        completion(.success(seatMapId))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case.failure(let error):
                completion(.failure(error))
                
            }
        }
    }
    
    func testFirebaseConnection() {
        print("🧪 Probando conexión con Firebase...")
        
        db.collection("seatMapTemplates").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Conexión fallida: \(error)")
                return
            }
            
            print("✅ Conexión exitosa. Documentos encontrados: \(snapshot?.documents.count ?? 0)")
            
            snapshot?.documents.forEach { doc in
                print("📋 Documento: \(doc.documentID)")
                print("📋 Datos completos: \(doc.data())")
            }
        }
    }
    
}
*/

import Foundation
import FirebaseFirestore
import Combine

class TemplateService: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchTemplates(completion: @escaping (Result<[SeatMapTemplate], Error>) -> Void) {
        print("🔄 Intentando cargar plantillas desde Firebase...")
        
        db.collection("seatMapTemplates")
            .order(by: "name")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error en consulta Firebase: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("📊 Snapshots recibidos: \(snapshot?.documents.count ?? 0) documentos")
                
                var templates: [SeatMapTemplate] = []
                
                for document in snapshot?.documents ?? [] {
                    print("📄 Procesando documento: \(document.documentID)")
                    let data = document.data()
                    
                    // Debug: mostrar todos los campos del documento
                    print("🔍 Campos del documento: \(data.keys.sorted())")
                    
                    do {
                        print("🔍 Intentando decodificar template...")
                        let template = try document.data(as: SeatMapTemplate.self)
                        templates.append(template)
                        print("✅ Template decodificado exitosamente: \(template.name)")
                        print("✅ StageData: \(template.stageData != nil ? "PRESENTE" : "AUSENTE")")
                        print("✅ Secciones: \(template.layoutData.sections.count)")
                        
                    } catch {
                        print("❌ ERROR en decodificación: \(error)")
                        print("❌ Error localizado: \(error.localizedDescription)")
                        
                        // Debug más detallado del error
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("❌ Key no encontrada: \(key), contexto: \(context)")
                            case .typeMismatch(let type, let context):
                                print("❌ Type mismatch: \(type), contexto: \(context)")
                            case .valueNotFound(let type, let context):
                                print("❌ Value no encontrado: \(type), contexto: \(context)")
                            case .dataCorrupted(let context):
                                print("❌ Data corrupta: \(context)")
                            @unknown default:
                                print("❌ Error desconocido")
                            }
                        }
                    }
                }
                
                print("✅ Templates finales: \(templates.count)")
                completion(.success(templates))
            }
    }
    
    func createSeatMapFromTemplate(template: SeatMapTemplate, eventId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let seatMap = SeatsMap(
            eventId: eventId,
            name: template.name,
            layoutData: template.layoutData
        )
        
        let eventService = EventService()
        eventService.createSeatMap(seatMap) { result in
            switch result {
            case .success(let seatMapId):
                var seatMapWithId = seatMap
                seatMapWithId.id = seatMapId
                
                eventService.initializeSeatsFromMap(seatMap: seatMapWithId) { seatResult in
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
    
    // Función temporal de test
    func testFirebaseConnection() {
        print("🧪 Probando conexión con Firebase...")
        
        db.collection("seatMapTemplates").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Conexión fallida: \(error)")
                return
            }
            
            print("✅ Conexión exitosa. Documentos encontrados: \(snapshot?.documents.count ?? 0)")
            
            snapshot?.documents.forEach { doc in
                print("📋 Documento: \(doc.documentID)")
                print("📋 Datos completos: \(doc.data())")
            }
        }
    }
}
