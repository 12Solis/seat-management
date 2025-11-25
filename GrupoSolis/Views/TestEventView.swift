//
//  TestEventView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

/*struct TestEventsView: View {
    @StateObject private var eventVM = EventViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedEventId: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Prueba de Eventos")
                    .font(.title)
                    .bold()
                
                // Botón para crear evento de prueba
                Button("Crear Evento de Prueba") {
                    eventVM.createTestEvent()
                }
                .buttonStyle(.borderedProminent)
                .disabled(eventVM.isLoading)
                
                // Botón para crear mapa de asientos de prueba
                if let eventId = selectedEventId ?? eventVM.events.first?.id {
                    Button("Crear Mapa de Asientos para este Evento") {
                        createTestSeatMapForEvent(eventId: eventId)
                    }
                    .buttonStyle(.bordered)
                    .disabled(eventVM.isLoading)
                    
                    NavigationLink("Ver Mapa de Asientos") {
                        /*SeatMapView(seatMapId: getSeatMapIdForEvent(eventId: eventId))
                            .environmentObject(authService)
                         */
                        /*SeatMapView(seatMapId: "t99kRZYFRASQXOM5lIIM") // ← Usa el ID que ves en los logs
                            .environmentObject(authService)*/
                        SeatMapView(seatMapId: eventId) // ← Usa el ID que ves en los logs
                            .environmentObject(authService)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Mostrar estado
                if eventVM.isLoading {
                    ProgressView("Cargando...")
                }
                
                if !eventVM.errorMessage.isEmpty {
                    Text(eventVM.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // Lista de eventos
                List(eventVM.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text("Lugar: \(event.place)")
                            .font(.subheadline)
                        Text("Fecha: \(event.date, style: .date)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        selectedEventId = event.id
                    }
                    .background(selectedEventId == event.id ? Color.blue.opacity(0.1) : Color.clear)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .padding()
            .onAppear {
                eventVM.fetchEvents()
            }
        }
    }
    
    private func createTestSeatMapForEvent(eventId: String) {
        let seatMapVM = SeatMapViewModel()
        seatMapVM.createTestSeatMapAndSeats(eventId: eventId) { result in
            switch result {
            case .success(let seatMapId):
                print("Mapa creado con ID: \(seatMapId)")
                // Guardar el seatMapId para usarlo después
                UserDefaults.standard.set(seatMapId, forKey: "seatMapId_\(eventId)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func getSeatMapIdForEvent(eventId: String) -> String {
        // En una app real, esto vendría de la base de datos
        // Por ahora usamos UserDefaults para guardar el ID temporalmente
        return UserDefaults.standard.string(forKey: "seatMapId_\(eventId)") ?? "test-map"
    }
}
 */

struct TestEventsView: View {
    @StateObject private var eventVM = EventViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedEventId: String? = nil
    @State private var isShowingTemplateSelection = false
    
    var body: some View{
        NavigationView{
            VStack(spacing:20){
                Text("Prueba de eventos")
                    .font(.title)
                    .padding()
                    .bold()
                
                
                Button("Crear evento de prueba"){
                    eventVM.createTestEvent()
                }
                .buttonStyle(.borderedProminent)
                .disabled(eventVM.isLoading)
                
                if let eventId = selectedEventId ?? eventVM.events.first?.id {
                    VStack(spacing:10){
                        Button("Crear mapa desde plantilla"){
                            isShowingTemplateSelection = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("Ver mapa de asientos"){
                            SeatMapView(seatMapId: getSeatMapIdForEvent(eventId: eventId))
                                .environmentObject(authService)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if eventVM.isLoading {
                    ProgressView("Cargando...")
                }
                
                if !eventVM.errorMessage.isEmpty {
                    Text(eventVM.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                List(eventVM.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text("Lugar: \(event.place)")
                            .font(.subheadline)
                        Text("Fecha: \(event.date, style: .date)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        selectedEventId = event.id
                    }
                    .background(selectedEventId == event.id ? Color.blue.opacity(0.1) : Color.clear)
                }
                .listStyle(.plain)
                Spacer()
                
            }
            .padding()
            .onAppear{
                eventVM.fetchEvents()
            }
            .sheet(isPresented: $isShowingTemplateSelection){
                if let eventId = eventVM.events.first?.id {
                   // print("🎪 Mostrando TemplateSelectionView para eventId: \(eventId)")
                    TemplateSelectionView(eventId: eventId)
                } else{
                    Text("No hay evento seleccionado")
                    .onAppear {
                        print("⚠️ No hay eventId para TemplateSelectionView")
                    }
                }
            }
        }
        
        
        
    }
    
    private func getSeatMapIdForEvent(eventId: String) -> String {
        return UserDefaults.standard.string(forKey: "seatMapId_\(eventId)") ?? "test-map"
    }
}

#Preview {
    TestEventsView()
        .environmentObject(AuthenticationService())
}
