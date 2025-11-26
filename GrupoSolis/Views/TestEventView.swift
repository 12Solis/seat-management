//
//  TestEventView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

struct TestEventsView: View {
    @StateObject private var eventVM = EventViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedEventId: String? = nil
    @State private var isShowingTemplateSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Gestor de Eventos")
                    .font(.title)
                    .bold()
                
                // ✅ NUEVO: Botón principal para crear evento desde plantilla
                Button("Crear Nuevo Evento desde Plantilla") {
                    isShowingTemplateSelection = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(eventVM.isLoading)
                
                // Mostrar eventos existentes
                if let eventId = selectedEventId ?? eventVM.events.first?.id {
                    NavigationLink("Ver Mapa de Asientos del Evento Seleccionado") {
                        SeatMapView(seatMapId: getSeatMapIdForEvent(eventId: eventId))
                            .environmentObject(authService)
                    }
                    .buttonStyle(.bordered)
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
                VStack(alignment: .leading) {
                    Text("Eventos Existentes (\(eventVM.events.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
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
                            print("✅ Evento seleccionado: \(event.name) - ID: \(event.id ?? "nil")")
                        }
                        .background(selectedEventId == event.id ? Color.blue.opacity(0.1) : Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Logout"){authService.signOut()})
            .padding()
            .onAppear {
                eventVM.fetchEvents()
            }
            .sheet(isPresented: $isShowingTemplateSelection) {
                TemplateSelectionView()
                    .onDisappear {
                        // Recargar eventos cuando se cierra el sheet (por si se creó uno nuevo)
                        eventVM.fetchEvents()
                    }
                
            }
        }
    }
    
    private func getSeatMapIdForEvent(eventId: String) -> String {
        return UserDefaults.standard.string(forKey: "seatMapId_\(eventId)") ?? "test-map"
    }
}

/*struct TestEventsView: View {
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
}*/

#Preview {
    TestEventsView()
        .environmentObject(AuthenticationService())
}
