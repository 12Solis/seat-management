//
//  EventViewModel.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import Foundation
import Combine
import FirebaseAuth

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let eventService = EventService()
    private var cancellables = Set<AnyCancellable>()
    
    
    func createTestEvent() {
        isLoading = true
        errorMessage = ""
        
        let testEvent = Event(
            name: "Concierto de Prueba",
            date: Date().addingTimeInterval(86400),
            place: "Estadio de Prueba"
        )
        
        eventService.createEvent(testEvent) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let eventId):
                    print("Evento creado con ID: \(eventId)")
                    self?.errorMessage = "Evento creado exitosamente! ID: \(eventId)"
                    
                    self?.fetchEvents()
                    
                case .failure(let error):
                    print("Error creando evento: \(error)")
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func createEvent(_ event: Event, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        errorMessage = ""
        
        eventService.createEvent(event) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let eventId):
                    print("Evento creado exitosamente: \(eventId)")
                    
                    self?.fetchEvents()
                    completion(.success(eventId))
                case .failure(let error):
                    self?.errorMessage = "Error creando evento: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func fetchEvents() {
        isLoading = true
        
        eventService.fetchEvents { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let events):
                    self?.events = events
                    print("Eventos cargados: \(events.count)")
                    
                case .failure(let error):
                    print("Error cargando eventos: \(error)")
                    self?.errorMessage = "Error cargando eventos: \(error.localizedDescription)"
                }
            }
        }
    }
}
