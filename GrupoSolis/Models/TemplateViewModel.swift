//
//  TemplateViewModel.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

/*import Foundation
import Combine

class TemplateViewModel: ObservableObject {
    @Published var templates: [SeatMapTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let templateService = TemplateService()
    
    func loadTemplates() {
        isLoading = true
        errorMessage = ""
        print("🎯 TemplateViewModel - Iniciando carga de plantillas")
        
        templateService.fetchTemplates {[weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let templates):
                    print("✅ TemplateViewModel - \(templates.count) plantillas cargadas exitosamente")
                    self?.templates = templates
                case .failure(let error):
                    print("❌ TemplateViewModel - Error: \(error.localizedDescription)")
                    self?.errorMessage = "Error cargando plantillas: \(error.localizedDescription)"
                }
            }
        }
        
    }
    
    func createFromTemplate(template: SeatMapTemplate, eventId:String, completion:@escaping(Result<String,Error>) -> Void){
        isLoading = true
        templateService.createSeatMapFromTemplate(template: template, eventId: eventId) {[weak self] result in
            DispatchQueue.main.async {
                self? .isLoading = false
                completion(result)
            }
        }
        
    }
    
    init() {
        templateService.testFirebaseConnection() // Temporal - quitar después
    }
    
}
*/
import Foundation
import Combine

class TemplateViewModel: ObservableObject {
    @Published var templates: [SeatMapTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let templateService = TemplateService()
    
    init() {
        // Quitar el test y cargar templates automáticamente
        loadTemplates()
    }
    
    func loadTemplates() {
        isLoading = true
        errorMessage = ""
        print("🎯 TemplateViewModel - Iniciando carga de plantillas")
        
        templateService.fetchTemplates { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let templates):
                    print("✅ TemplateViewModel - \(templates.count) plantillas cargadas exitosamente")
                    self?.templates = templates
                    
                    // Debug adicional
                    if templates.isEmpty {
                        print("⚠️ TemplateViewModel - templates está vacío")
                    } else {
                        templates.forEach { template in
                            print("📋 Template cargado: \(template.name)")
                        }
                    }
                    
                case .failure(let error):
                    print("❌ TemplateViewModel - Error: \(error.localizedDescription)")
                    self?.errorMessage = "Error cargando plantillas: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func createFromTemplate(template: SeatMapTemplate, eventId: String, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        
        templateService.createSeatMapFromTemplate(template: template, eventId: eventId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(result)
            }
        }
    }
}
